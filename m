From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [RFC PATCH 00/11] an introduction of library operating system for
 Linux (LibOS)
Date: Fri, 27 Mar 2015 04:49:55 +0100
Message-ID: <CAMuHMdXYa2K8FH48A8_O-TsfduUC2A2WWD_bHhBgznf6FbN1Zw@mail.gmail.com>
References: <1427202642-1716-1-git-send-email-tazaki@sfc.wide.ad.jp>
	<551164ED.5000907@nod.at>
	<m2twxacw13.wl@sfc.wide.ad.jp>
	<55117565.6080002@nod.at>
	<m2sicuctb2.wl@sfc.wide.ad.jp>
	<55118277.5070909@nod.at>
	<m2bnjhcevt.wl@sfc.wide.ad.jp>
	<55133BAF.30301@nod.at>
	<m2h9t7bubh.wl@wide.ad.jp>
	<5514560A.7040707@nod.at>
	<87iodnqfp1.fsf@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Richard Weinberger <richard@nod.at>,
	Hajime Tazaki <tazaki@wide.ad.jp>,
	Linux-Arch <linux-arch@vger.kernel.org>,
	Arnd Bergmann <arnd@arndb.de>,
	Jonathan Corbet <corbet@lwn.net>,
	Christoph Lameter <cl@linux.com>,
	Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Linux MM <linux-mm@kvack.org>, Jeff Dike <jdike@addtoit.com>,
	mathieu.lacage@gmail.com
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <87iodnqfp1.fsf@rustcorp.com.au>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 27, 2015 at 4:31 AM, Rusty Russell <rusty@rustcorp.com.au> wrote:
> Richard Weinberger <richard@nod.at> writes:
>> This also infers that arch/lib will be broken most of the time as
>> every time the networking stack references a new symbol it
>> has to be duplicated into arch/lib.
>>
>> But this does not mean that your idea is bad, all I want to say that
>> I'm not sure whether arch/lib is the right approach.
>> Maybe Arnd has a better idea.
>
> Exactly why I look forward to getting this in-tree.  Jeremy Kerr and I
> wrote nfsim back in 2005(!) which stubbed around the netfilter
> infrastructure; with failtest and valgrind it found some nasty bugs.  It
> was too much hassle to maintain out-of-tree though :(
>
> I look forward to a flood of great bugfixes from this work :)

IIRC, the ability to run UML under valgrind was also one of its key features?
And that's not limited to networking.

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
