From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [GIT] Networking
Date: Thu, 3 Sep 2015 11:22:10 -0700
Message-ID: <CA+55aFxtD2VYW2R0JwjFkZkvzQzcN7qK3m6ReR+BBXtfyDHx7g@mail.gmail.com>
References: <20150902.223522.1792493140210966693.davem@davemloft.net>
	<CA+55aFx=xh4+vCNOgwXyfeV-t=6anXimqBxH_i71RjYy+Gy9-w@mail.gmail.com>
	<20150903.104032.767889134756094076.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Lorenzo Bianconi <lorenzo.bianconi83@gmail.com>,
	Johannes Berg <johannes.berg@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150903.104032.767889134756094076.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 3, 2015 at 10:40 AM, David Miller <davem@davemloft.net> wro=
te:
>
> Linus, what GCC version are you using and what does the warning look
> like?

I'm on whatever is in F22. gcc -v says

   gcc version 5.1.1 20150618 (Red Hat 5.1.1-4) (GCC)

and the warning looks like so:

  net/mac80211/rate.c: In function =E2=80=98rate_control_cap_mask=E2=80=
=99:
  net/mac80211/rate.c:719:25: warning: =E2=80=98sizeof=E2=80=99 on arra=
y function
parameter =E2=80=98mcs_mask=E2=80=99 will return size of =E2=80=98u8 * =
{aka unsigned char *}=E2=80=99
[-Wsizeof-array-argument]
     for (i =3D 0; i < sizeof(mcs_mask); i++)
                           ^

(note the lack of warning about the use of an array in the function
definition parameter list - I tried to find if there's any way to
enable such a warning, but couldn't find anything. Maybe my google-fu
is weak, but more probably that just doesn't exist).

                      Linus
