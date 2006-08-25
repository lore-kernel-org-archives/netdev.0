From: Mohamed Abbas <mabbas@linux.intel.com>
Subject: Re: [PATCH 01/3] d80211:  add support for SIOCSIWRATE, SIOCSIWTXPOW
 and SIOCSIWPOWER
Date: Fri, 25 Aug 2006 11:46:04 -0700
Message-ID: <44EF456C.8060603@linux.intel.com>
References: <20060821074107.648561364@sipsolutions.net> <20060821075158.728615077@sipsolutions.net> <44EA501E.4010605@linux.intel.com> <20060825183749.GA2292@instant802.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.21]:41253 "EHLO
	orsmga101.jf.intel.com") by vger.kernel.org with ESMTP
	id S964879AbWHYSqF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Aug 2006 14:46:05 -0400
To: Jouni Malinen <jkm@devicescape.com>
In-Reply-To: <20060825183749.GA2292@instant802.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I will separate each pair of S/G in separate patch so it will be easier 
to discuss each set separately. I will provide the patch this weekend 
taking into account the comments provided

Thanks
Mohamed
Jouni Malinen wrote:

>On Mon, Aug 21, 2006 at 05:30:22PM -0700, Mohamed Abbas wrote:
>
>  
>
>>the attached patch will add support to handle these iw_handle 
>>SIOC[S/G]IWRATE, SIOC[S/G]IWTXPOW and SIOC[S/G]IWPOWER.  It also  added 
>>some changes in ieee80211_ioctl_giwrange function to report supported 
>>channels and rates.  a call to ieee80211_hw_config is needed to infor 
>>the low level driver about these changes, I guess we might need to add 
>>flag to indicate which parameters was changed so the low level driver 
>>does not need to make extra calls.
>>    
>>
>
>Could you please separate SIOCSIWRATE from the rest. I did not go
>through the details yet, but I do not think the proposed change here
>would match the the way rate control was designed in the Devicescape
>stack and I would not like to see this getting in before more careful
>review and explanation of how this is expected to work. The way I see
>rate settings working is that the control would be applied to the rate
>control algorithm and not to the list of rates itself.
>
>  
>
