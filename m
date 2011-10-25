From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [GIT] Networking
Date: Tue, 25 Oct 2011 14:03:09 +0200
Message-ID: <CA+55aFzYW_Pku3ESH8HHHkGMu+G9UZPUSLajZy=edEnQ+vycNg@mail.gmail.com>
References: <20111025.063206.2273357152859701628.davem@davemloft.net>
 <CA+55aFw1GVvszqoC_f0RAvG5t1xj0CSYLhLU=y0gQ+_54Gsomw@mail.gmail.com> <20111025115634.GA12128@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Mikulas Patocka <mpatocka@redhat.com>,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Greg KH <gregkh@suse.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111025115634.GA12128@suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 25, 2011 at 1:56 PM, Greg KH <gregkh@suse.de> wrote:
>
> The "crazy" tool was using 'git am'. =A0The problem was that I missed=
 the
> fact that the first line of the patch sent to me duplicated the subje=
ct
> line. =A0It's a really common problem when people generate patches an=
d
> send them off by email, I just forgot to edit the patches from Mikula=
s
> to remove them, my fault, sorry.

Ok, please (a) check these things before applying patches, and (b)
COMPLAIN TO EVERY SOURCE THAT SENDS YOU CRAP.

The push-back so that it doesn't happen again is important.

In other words: Mikulas - whatever tool you're using, stop using it,
or start using it correctly. Duplicating the header line in the body
of the email is crap and wrong. If you want to duplicate it in the
email, add the "Subject:" prefix to it (same goes for "Date:" and
particularly "From:" - those fields are actually destroyed by
forwarding the patches over email - unlike the subject line)

             Linus
