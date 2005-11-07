From: Yan Zheng <yzcorp@gmail.com>
Subject: Re: [PATCH][MCAST]Clear MAF_GSQUERY flag when process MLDv1 general query messages.
Date: Mon, 7 Nov 2005 22:46:20 +0800
Message-ID: <7e77d27c0511070646o7b8686aes@mail.gmail.com>
References: <436F610E.8010400@21cn.com> <20051107142517.GA13797@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750796AbVKGOqW@vger.kernel.org>
To: Yan Zheng <yanzheng@21cn.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, David Stevens <dlstevens@us.ibm.com>
In-Reply-To: <20051107142517.GA13797@tuxdriver.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Could you be more specific about what problem it will cause?
>
> Thanks,
>
> John
> --
> John W. Linville
> linville@tuxdriver.com


If the first query message receive after expiration is MLDv2 general
query and MAF_GSQUERY flag is set. The report message only contains
sources marked by last MLDv2 Multicast Address and Source Specific
Queries . Although this circumstance happens  rare, I think it's
better have it fixed


Regards
