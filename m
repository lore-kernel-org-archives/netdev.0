From: "David S. Miller" <davem@redhat.com>
Subject: Re: [Fwd: [patch] fix slot clash in sch_sfq.c]
Date: Wed, 11 Feb 2004 19:35:31 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040211193531.685c73c6.davem@redhat.com>
References: <1076532461.19204.50.camel@pitanga.ldhs.cetuc.puc-rio.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Miguel Freitas <miguel@cetuc.puc-rio.br>
In-Reply-To: <1076532461.19204.50.camel@pitanga.ldhs.cetuc.puc-rio.br>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 11 Feb 2004 18:47:41 -0200
Miguel Freitas <miguel@cetuc.puc-rio.br> wrote:

> I better send a copy of this one to the mailing list...

Your patch is correct.  It is amusing that sfq_drop() was handling
this correctly yet sfq_dequeue() was not.  In fact, this breaks
pretty seriously the behavior of this scheduler as you've noted.
