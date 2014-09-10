From: Randy Dunlap <rdunlap@infradead.org>
Subject: Re: linux-next: Tree for Sep 10 (bpf)
Date: Wed, 10 Sep 2014 09:50:38 -0700
Message-ID: <5410815E.4080608@infradead.org>
References: <20140910185920.336180d4@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>, linux-next@vger.kernel.org
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20140910185920.336180d4@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/10/14 01:59, Stephen Rothwell wrote:
> Hi all,
> 
> Changes since 20140909:
> 

When CONFIG_MODULES is not enabled:  (seen on i386 and x86_64)

kernel/built-in.o: In function `bpf_jit_binary_alloc':
(.text+0x7689d): undefined reference to `module_alloc'
kernel/built-in.o: In function `bpf_jit_binary_free':
(.text+0x768f0): undefined reference to `module_free'


-- 
~Randy
