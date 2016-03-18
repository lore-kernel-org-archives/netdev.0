From: "Evgeny Cherkashin" <Eugene.Crosser@ru.ibm.com>
Subject: Re: [PATCH] qeth: Default to allow promiscuous mode
Date: Fri, 18 Mar 2016 13:07:34 +0000
Message-ID: <201603181207.u2IC7muq030383@d06av10.portsmouth.uk.ibm.com>
References: <56EBCC28.5090500@suse.de>,<1458234085-217667-1-git-send-email-agraf@suse.de>
 <201603171752.u2HHq7hM025196@d06av11.portsmouth.uk.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-s390@vger.kernel.org, linux-kernel@vger.kernel.org,
	heicars2@linux.vnet.ibm.com, mschwid2@linux.vnet.ibm.com,
	Ursula Braun <ubraun@linux.vnet.ibm.com>, ihno@suse.de,
	mt@suse.com, pwieczorkiewicz@suse.de,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Alexander Graf <agraf@suse.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56EBCC28.5090500@suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Alexander,

-----Alexander Graf <agraf@suse.de> wrote: -----

send it explicitly if that makes it move obvious, sure.
>
>> 3. The patch should probably go via the -networking maillist.
>
>Ah, get_maintainers.pl didn't list it. You may want to send a patch
>for
>the MAINTAINERS file here :).

My mistake, you've sent it to the right place.

About the nature of the patch:

- Enabling bridgeport on adaptors on which bridgeport is already used b=
y somebody else will break somebody else's operation.

- Therefore, system administrator must only enable bridgeport on adapto=
rs on which nobody else tries to use it (without coordinating with them=
).

- Making bridge_reflect_promisc enabled by default makes it impossible.

- Therefore, bridge_reflect_promisc must not be enabled by default.

(Those who enable bridge_reflect_promisc blindly on all adaptors will b=
reak their users' setup, and will have to deal with the consequences.)

Regards,

Evgeny Cherkashin / =D0=95=D0=B2=D0=B3=D0=B5=D0=BD=D0=B8=D0=B9 =D0=A7=D0=
=B5=D1=80=D0=BA=D0=B0=D1=88=D0=B8=D0=BD / Eugene Crosser (preferred)
Software Engineer, IBM Science and Technology Center, Linux on z-System=
s Development
tel. +7 495 775 8800 ext.1103, Moscow 123317, Presnenskaya emb. 10
