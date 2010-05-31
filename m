From: Ben Gardiner <bengardiner-ScDXFp4xN3PN+rMO2ozGnw@public.gmane.org>
Subject: Re: Network QoS support in applications
Date: Mon, 31 May 2010 15:30:31 -0400
Message-ID: <AANLkTindWCmxtAJU5R3ey_18_3wNUuMGc-jq_EY_itiN@mail.gmail.com>
References: <87my01m0zm.fsf@purkki.valot.fi>
	<4B5EF5DF.2070005@lemonia.org>
	<4B9942A7.40205@redfish-solutions.com>
	<20100311.112754.142886660.davem@davemloft.net>
	<4B9944A0.5080308@redfish-solutions.com>
	<4BF32B2B.6010202@redfish-solutions.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, dunc-9b9L1Hpe0sBAfugRpC6u6w@public.gmane.org,
	kalle.valo-X3B1VOXEql0@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "Philip A. Prindeville" <philipp-9z15yex7P+UJvtFkdXX2HpqQE7yCjDx5@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4BF32B2B.6010202-9z15yex7P+UJvtFkdXX2HpqQE7yCjDx5@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, May 18, 2010 at 8:04 PM, Philip A. Prindeville
<philipp-9z15yex7P+UJvtFkdXX2HpqQE7yCjDx5@public.gmane.org> wrote:
> On 03/11/2010 12:29 PM, Philip A. Prindeville wrote:
>> On 03/11/2010 12:27 PM, David Miller wrote:
>>
>>> From: "Philip A. Prindeville" <philipp_subx-9z15yex7P+UJvtFkdXX2HpqQE7yCjDx5@public.gmane.org>
>>> Date: Thu, 11 Mar 2010 12:21:11 -0700
>>>
>>>
>>>> And yes, there will always be misbehaving users. =A0They are a fac=
t of
>>>> life. =A0That doesn't mean we should lobotomize the network. =A0We=
 don't
>>>> have an authentication mechanism on ICMP Redirects or Source-Quenc=
h,
>>>>
>>> Which is why most networks block those packets from the outside.
>>>
>>>
>>>> Nor is ARP authenticated.
>>>>
>>> Which is why people control who can plug into their physical
>>> network.
>>>
>>> None of the things you are saying support the idea of having
>>> applications decide what the DSCP marking should be.
>>>
>>
>> Does "decide what the DSCP marking should be" include complying to t=
he recommendations of RFC-4594?
>>
>
> If anyone cares, here's an update:
>
> I've submitted patches for QoS configuration for:
>
> APR/Apache (stalled);
> Proftpd (committed);
> Openssh (pending review);
> Firefox/Thunderbird (reviewed and on-track for commit);
> Cyrus (committed);
> Sendmail (submittted and acknowledged, but not yet reviewed);
> Curl (stalled);
>
> All, as per the request of the maintainers, default to either no QoS
> markings or previous RFC-791 QoS markings if that's what they already
> supported (Proftpd and Openssh).
>
> If anyone can think of anything else that needs to be supported to
> impact a significant portion of network (or enterprise intranet)
> traffic, please call it out.

wget [1], like curl, is used for downloads of artifacts by some build s=
ystems.

[1] http://www.gnu.org/software/wget/

--=20
Ben Gardiner
Nanometrics Inc.
+1 (613) 592-6776 x239
http://www.nanometrics.ca
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
