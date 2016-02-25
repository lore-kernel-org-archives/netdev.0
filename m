From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] ipv4: in new netns initialize sysctls in
	net.ipv4.conf.* with defaults
Date: Thu, 25 Feb 2016 11:43:43 -0500 (EST)
Message-ID: <20160225.114343.1977846344387184355.davem@davemloft.net>
References: <20160223.182121.2101846699151527296.davem@davemloft.net>
	<87y4a9ix2h.fsf@x220.int.ebiederm.org> <56CF0DC0.7030003@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: khlebnikov-XoJtRXgx1JseBXzfvpsJ4g@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, vvs-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org
To: nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <56CF0DC0.7030003-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Nicolas Dichtel <nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>
Date: Thu, 25 Feb 2016 15:20:48 +0100

> Le 24/02/2016 23:05, Eric W. Biederman a =E9crit :
> [snip]
>> In the general case the current behavior is random and not something
>> applications can count on, and we would do well to fix it so it is
>> less
>> random.  In particular consider the case of an application in a
>> non-initial network namespace creating a new network namespace.  It is
>> not even possible to predict what values they will get for sysctls
>> today.
> +1

But there is a counter argument to this.

The admin set up the initial namespace so that any namespace
instantiated by a user (even non-initial namespaces) starts with a
specific set of sysctl values.  So the admin "knows", he set it up
intentionally this way, and it's a valid model.

This behavior is anything but random.  Rather, it is very predictable
and controllable.

Do you really want to find out who you're going to break out there with
so many installations in the world right now?

I do not.
