From: "Jouni Malinen" <jkm@devicescape.com>
Subject: Re: Request to postpone WE-21
Date: Thu, 5 Oct 2006 15:15:50 -0700
Message-ID: <20061005221550.GJ17517@instant802.com>
References: <20061005163113.GB6510@bougret.hpl.hp.com> <20061005204949.GF18408@tuxdriver.com> <20061005221246.GB7533@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org,
	jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-64.dex002.intermedia.net ([64.78.20.13]:6852 "EHLO
	dhost002-64.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S932359AbWJEWP6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Oct 2006 18:15:58 -0400
To: Jean Tourrilhes <jt@hpl.hp.com>
Content-Disposition: inline
In-Reply-To: <20061005221246.GB7533@bougret.hpl.hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 05, 2006 at 03:12:46PM -0700, Jean Tourrilhes wrote:
> +			if((cmd == SIOCSIWESSID) ||
> +			   (cmd == SIOCSIWNICKN)) {
> +				if(extra[iwr->u.data.length - 1] == '\0') {

Can't iwr->u.data.length be zero here (with WE-21)? Maybe better add
'iwr->u.data.length > 0 &&'..

-- 
Jouni Malinen                                            PGP id EFC895FA
