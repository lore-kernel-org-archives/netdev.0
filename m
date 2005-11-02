From: Willy Tarreau <willy@w.ods.org>
Subject: Re: [PATCH][MCAST]IPv6: small fix for ip6_mc_msfilter(...)
Date: Wed, 2 Nov 2005 06:47:02 +0100
Message-ID: <20051102054702.GB11266@alpha.home.local>
References: <436586F0.9080101@21cn.com> <7e77d27c0511010237x775529b8h@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	David Stevens <dlstevens@us.ibm.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751525AbVKBF6M@vger.kernel.org>
To: Yan Zheng <yzcorp@gmail.com>
Content-Disposition: inline
In-Reply-To: <7e77d27c0511010237x775529b8h@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Tue, Nov 01, 2005 at 06:37:43PM +0800, Yan Zheng wrote:
> You can reproduce this bug by follow codes. This program will cause a
> change to include report even though the first socket's filter mode is
> exclude.

I've not clearly understood the nature of the bug, does it also
affect 2.4 ? Marcelo will be releasing 2.4.32 in a few days, so
it would be wise to merge the fix soon.

Regards,
Willy
