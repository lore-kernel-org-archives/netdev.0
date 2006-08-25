From: "Jouni Malinen" <jkm@devicescape.com>
Subject: Re: [PATCH 01/3] d80211:  add support for SIOCSIWRATE, SIOCSIWTXPOW and SIOCSIWPOWER
Date: Fri, 25 Aug 2006 11:37:49 -0700
Message-ID: <20060825183749.GA2292@instant802.com>
References: <20060821074107.648561364@sipsolutions.net> <20060821075158.728615077@sipsolutions.net> <44EA501E.4010605@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-32.dex002.intermedia.net ([64.78.21.117]:34333 "EHLO
	dhost002-32.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S964879AbWHYShz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Aug 2006 14:37:55 -0400
To: Mohamed Abbas <mabbas@linux.intel.com>
Content-Disposition: inline
In-Reply-To: <44EA501E.4010605@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 21, 2006 at 05:30:22PM -0700, Mohamed Abbas wrote:

> the attached patch will add support to handle these iw_handle 
> SIOC[S/G]IWRATE, SIOC[S/G]IWTXPOW and SIOC[S/G]IWPOWER.  It also  added 
> some changes in ieee80211_ioctl_giwrange function to report supported 
> channels and rates.  a call to ieee80211_hw_config is needed to infor 
> the low level driver about these changes, I guess we might need to add 
> flag to indicate which parameters was changed so the low level driver 
> does not need to make extra calls.

Could you please separate SIOCSIWRATE from the rest. I did not go
through the details yet, but I do not think the proposed change here
would match the the way rate control was designed in the Devicescape
stack and I would not like to see this getting in before more careful
review and explanation of how this is expected to work. The way I see
rate settings working is that the control would be applied to the rate
control algorithm and not to the list of rates itself.

-- 
Jouni Malinen                                            PGP id EFC895FA
