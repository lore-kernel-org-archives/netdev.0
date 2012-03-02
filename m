From: =?ISO-8859-15?Q?Niccol=F2_Belli?= <darkbasic-DEeHIYRtcplPMsqi6aon0Q@public.gmane.org>
Subject: Re: Strange issue with IPv6 through ipsec
Date: Fri, 02 Mar 2012 14:19:08 +0100
Message-ID: <4F50C8CC.2040106@linuxsystems.it>
References: <4F4EB820.1090607@linuxsystems.it>
	<4F4EBCE3.8040301@linuxsystems.it>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-15"
Content-Transfer-Encoding: quoted-printable
Cc: users-3+4lAyCyj6DkhV4RL1hkzWD2FQJk+8+b@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <users-bounces+gnvsu-users=m.gmane.org-3+4lAyCyj6DkhV4RL1hkzWD2FQJk+8+b@public.gmane.org>
In-Reply-To: <4F4EBCE3.8040301-DEeHIYRtcplPMsqi6aon0Q@public.gmane.org>
List-Unsubscribe: <https://lists.strongswan.org/mailman/listinfo/users>,
	<mailto:users-request-3+4lAyCyj6DkhV4RL1hkzWD2FQJk+8+b@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.strongswan.org/pipermail/users>
List-Post: <mailto:users-3+4lAyCyj6DkhV4RL1hkzWD2FQJk+8+b@public.gmane.org>
List-Help: <mailto:users-request-3+4lAyCyj6DkhV4RL1hkzWD2FQJk+8+b@public.gmane.org?subject=help>
List-Subscribe: <https://lists.strongswan.org/mailman/listinfo/users>,
	<mailto:users-request-3+4lAyCyj6DkhV4RL1hkzWD2FQJk+8+b@public.gmane.org?subject=subscribe>
Sender: users-bounces+gnvsu-users=m.gmane.org-3+4lAyCyj6DkhV4RL1hkzWD2FQJk+8+b@public.gmane.org
Errors-To: users-bounces+gnvsu-users=m.gmane.org-3+4lAyCyj6DkhV4RL1hkzWD2FQJk+8+b@public.gmane.org
List-Id: netdev.vger.kernel.org

Sorry for the dumb question, it isn't a bug and I found the answer using =

dcpdump:

listening on eth0, link-type EN10MB (Ethernet), capture size 65535 bytes
14:09:40.891358 IP6 a:b:c:301::1 > ff02::1:ff00:2: ICMP6, neighbor =

solicitation, who has a:b:c:301::2, length 32
14:09:40.891708 IP6 a:b:c:301::2 > a:b:c:301::1: ICMP6, neighbor =

advertisement, tgt is a:b:c:301::2, length 32
14:09:40.891727 IP6 a:b:c:301::1 > a:b:c:301::2: ICMP6, echo request, =

seq 1, length 64
14:09:40.891778 IP6 a:b:c:301::2 > a:b:c:301::1: ICMP6, echo reply, seq =

1, length 64
14:09:41.887406 IP6 a:b:c:301::1 > a:b:c:301::2: ICMP6, echo request, =

seq 2, length 64
14:09:41.887478 IP6 a:b:c:301::2 > a:b:c:301::1: ICMP6, echo reply, seq =

2, length 64
14:09:42.887391 IP6 a:b:c:301::1 > a:b:c:301::2: ICMP6, echo request, =

seq 3, length 64
14:09:42.887440 IP6 a:b:c:301::2 > a:b:c:301::1: ICMP6, echo reply, seq =

3, length 64
14:09:43.886647 IP6 a:b:c:301::1 > a:b:c:301::2: ICMP6, echo request, =

seq 4, length 64
14:09:43.886716 IP6 a:b:c:301::2 > a:b:c:301::1: ICMP6, echo reply, seq =

4, length 64
14:09:44.886636 IP6 a:b:c:301::1 > a:b:c:301::2: ICMP6, echo request, =

seq 5, length 64
14:09:44.886687 IP6 a:b:c:301::2 > a:b:c:301::1: ICMP6, echo reply, seq =

5, length 64
14:09:45.886651 IP6 a:b:c:301::1 > a:b:c:301::2: ICMP6, echo request, =

seq 6, length 64
14:09:45.886722 IP6 a:b:c:301::2 > a:b:c:301::1: ICMP6, echo reply, seq =

6, length 64
14:09:45.889830 IP6 fe80::211:d8ff:fed9:c01a > a:b:c:301::1: ICMP6, =

neighbor solicitation, who has a:b:c:301::1, length 32
14:09:45.889866 IP6 a:b:c:301::1 > fe80::211:d8ff:fed9:c01a: ICMP6, =

neighbor advertisement, tgt is a:b:c:301::1, length 24


I simply had to passthrough multicast link-local traffic.

I'm sorry but I'm really newbie to IPv6 :(

Regards,
Niccol=F2
