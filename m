From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v3 4/8] x86: stop exporting msr-index.h to userland
Date: Fri, 13 Jan 2017 17:38:36 +0100
Message-ID: <20170113163836.jn3u6xyfcrbtynut@pd.tnic>
References: <1484304406-10820-5-git-send-email-nicolas.dichtel@6wind.com>
 <3131144.4Ej3KFWRbz@wuerfel>
 <1484304406-10820-1-git-send-email-nicolas.dichtel@6wind.com>
 <25483.1484322229@warthog.procyon.org.uk>
 <dd826bc7-e1ef-be29-e0c3-692afb346036@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: David Howells <dhowells@redhat.com>, arnd@arndb.de,
        linux-kbuild@vger.kernel.org, linux-doc@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org,
        linux-snps-arc@lists.infradead.org,
        linux-arm-kernel@lists.infradead.org,
        adi-buildroot-devel@lists.sourceforge.net,
        linux-c6x-dev@linux-c6x.org, linux-cris-kernel@axis.com,
        uclinux-h8-devel@lists.sourceforge.jp,
        linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org,
        linux-m68k@vger.kernel.org, linux-metag@vger.kernel.org,
        linux-mips@linux-mips.org, linux-am33-list@redhat.com,
        nios2-dev@lists.rocketboards.org, openrisc@lists.librecores.org,
        linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
        linux-s390@vger.kernel.org, linux-sh@vger.kernel.org,
        sparclinux@vger.kernel.org, linux-xtensa@linux-xtens
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <linux-sh-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <dd826bc7-e1ef-be29-e0c3-692afb346036@6wind.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 13, 2017 at 05:08:34PM +0100, Nicolas Dichtel wrote:
> Le 13/01/2017 à 16:43, David Howells a écrit :
> >> -header-y += msr-index.h
> > 
> > I see it on my desktop as /usr/include/asm/msr-index.h and it's been there at
> > least four years - and as such it's part of the UAPI.  I don't think you can
> > remove it unless you can guarantee there are no userspace users.
> I keep it in the v2 of the series, but the maintainer, Borislav Petkov, asks me
> to un-export it.
> 
> I will follow the maintainer decision.

I'm not the maintainer. I simply think that exporting that file was
wrong because it if we change something in it, we will break userspace.
And that should not happen - if userspace needs MSRs, it should do its
own defines.

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.
