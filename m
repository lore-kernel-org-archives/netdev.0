From: David Howells <dhowells@redhat.com>
Subject: Re: [-mm patch] fix fs/nfs/nfsroot.c compile error
Date: Mon, 07 May 2007 16:49:57 +0100
Message-ID: <20340.1178552997@redhat.com>
References: <1178543543.6158.7.camel@heimdal.trondhjem.org>  <20070505164422.GD8975@stusta.de> <20070505014955.8f3990b5.akpm@linux-foundation.org> <15958.1178534871@redhat.com> <20070507105607.GB4226@stusta.de>
Cc: Adrian Bunk <bunk@stusta.de>,
	Andrew Morton <akpm@linux-foundation.org>, davem@davemloft.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S934422AbXEGPwS@vger.kernel.org>
In-Reply-To: <1178543543.6158.7.camel@heimdal.trondhjem.org> 
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Trond Myklebust <trond.myklebust@fys.uio.no> wrote:

> It makes little or no sense to be forcing attributes like 'const' in a
> typedef. That is basically stating that it is inconceivable to use
> anything else. Clearly not the case here...

Yeah.  I think that there shouldn't be a typedef.  There's no real need for
it.

David
