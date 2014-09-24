From: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Subject: Re: [RFC PATCH net-next v2 0/5] netns: allow to identify peer netns
Date: Wed, 24 Sep 2014 10:05:59 -0700
Message-ID: <CALCETrXMkV_1XR2mXOoO_2_vpB=6cPbWAAOhPFhPbDa_1P+zxw@mail.gmail.com>
References: <1411478430-4989-1-git-send-email-nicolas.dichtel@6wind.com>
 <CALCETrWnZtWstBviDxcHpLpjHF3R+sgS48RYf2pbKBYeExZVOQ@mail.gmail.com> <54228F8B.2030804@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
	Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
To: Nicolas Dichtel <nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <54228F8B.2030804-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 24, 2014 at 2:31 AM, Nicolas Dichtel
<nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org> wrote:
> Le 23/09/2014 21:26, Andy Lutomirski a =C3=A9crit :
>
>> On Tue, Sep 23, 2014 at 6:20 AM, Nicolas Dichtel
>> <nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org> wrote:
>>>
>>> The goal of this serie is to be able to multicast netlink messages =
with
>>> an
>>> attribute that identify a peer netns.
>>> This is needed by the userland to interpret some informations conta=
ined
>>> in
>>> netlink messages (like IFLA_LINK value, but also some other attribu=
tes in
>>> case
>>> of x-netns netdevice (see also
>>> http://thread.gmane.org/gmane.linux.network/315933/focus=3D316064 a=
nd
>>> http://thread.gmane.org/gmane.linux.kernel.containers/28301/focus=3D=
4239)).
>>>
>>> Ids are stored in the parent user namespace. These ids are valid on=
ly
>>> inside
>>> this user namespace. The user can retrieve these ids via a new netl=
ink
>>> messages,
>>> but only if peer netns are in the same user namespace.
>>
>>
>> What about the parent / ancestors of the owning userns?  Can process=
es
>> in those usernses see any form of netns id?
>
> With this serie no. I'm not sure if ancestors really needs to be able=
 to
> get these ids. What is your opinion?

I might be missing some consideration here, but I would hope that ip
link would work correctly if I have a veth interface shared with a
netns that's in a child userns.

--Andy

--=20
Andy Lutomirski
AMA Capital Management, LLC
