From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: next: arm64: LTP sendto01 test causes system crash in ilp32 mode
Date: Wed, 11 Oct 2017 11:41:53 -0700
Message-ID: <1507747313.31614.27.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20171011183522.tm2xxgzbdspjtsax@yury-thinkpad>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        netdev@vger.kernel.org, Catalin Marinas <catalin.marinas@arm.com>,
        "David S. Miller" <davem@davemloft.net>,
        Florian Westphal <fw@strlen.de>
To: Yury Norov <ynorov@caviumnetworks.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171011183522.tm2xxgzbdspjtsax@yury-thinkpad>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2017-10-11 at 21:35 +0300, Yury Norov wrote:
> Hi all, 
> 
> It seems like next-20171009 with ilp32 patches crashes on LTP sendto01 test
> in sys_sendto() path, like this:

Thanks for the report.
Probably caused by one of my recent patches, so I am taking a look.
