From: Arnaldo Carvalho de Melo <arnaldo.melo@gmail.com>
Subject: Re: TCP4/6 socket closure causing system crash..
Date: Wed, 4 May 2005 13:16:17 -0300
Message-ID: <39e6f6c705050409161b90858b@mail.gmail.com>
References: <20050504125752.GA7399@mea-ext.zmailer.org>
Reply-To: acme@ghostprotocols.net
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: Matti Aarnio <matti.aarnio@zmailer.org>
In-Reply-To: <20050504125752.GA7399@mea-ext.zmailer.org>
Content-Disposition: inline
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 5/4/05, Matti Aarnio <matti.aarnio@zmailer.org> wrote:
> I have CVS-pserver running under a chroot wrapper.
> Recently system has become unresponsive the instance somebody
> refers to the pserver...
> 
> I have three kernels to choose from:
> 
>   title Fedora Core (2.6.11-1.1282_FC4smp)
>   title Fedora Core (2.6.11-1.1276_FC4smp)
>   title Fedora Core (2.6.11-1.1191_FC4smp)
> 
> First two crash, third works just fine for this workset.
> 
> Serial console capture tells following:
> 
>    -----------------
> 
> Kernel 2.6.11-1.1282_FC4smp on an i686
> 
> mismatch in kmem_cache_free: expected cache f78ee500, got f7972800

Look at https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=155389

Try with the sk_prot_creator patch.

- Arnaldo
