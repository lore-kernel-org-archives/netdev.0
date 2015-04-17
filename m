From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC PATCH v2 02/11] slab: add private memory allocator header
 for arch/lib
Date: Fri, 17 Apr 2015 07:17:42 -0500 (CDT)
Message-ID: <alpine.DEB.2.11.1504170716380.20800@gentwo.org>
References: <1427202642-1716-1-git-send-email-tazaki@sfc.wide.ad.jp> <1429263374-57517-1-git-send-email-tazaki@sfc.wide.ad.jp> <1429263374-57517-3-git-send-email-tazaki@sfc.wide.ad.jp>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-arch@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>,
	Jonathan Corbet <corbet@lwn.net>,
	Jekka Enberg <penberg@kernel.org>,
	Javid Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Jndrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org,
	netdev@vger.kernel.org, linux-mm@kvack.org,
	Jeff Dike <jdike@addtoit.com>,
	Richard Weinberger <richard@nod.at>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Ryo Nakamura <upa@haeena.net>,
	Christoph Paasch <christoph.paasch@gmail.com>,
	Mathieu Lacage <mathieu.lacage@gmail.com>,
	libos-nuse@googlegroups.com
To: Hajime Tazaki <tazaki@sfc.wide.ad.jp>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1429263374-57517-3-git-send-email-tazaki@sfc.wide.ad.jp>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 17 Apr 2015, Hajime Tazaki wrote:

> add header includion for CONFIG_LIB to wrap kmalloc and co. This will
> bring malloc(3) based allocator used by arch/lib.

Maybe add another allocator insteadl? SLLB which implements memory
management using malloc()?
