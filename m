From: Andreas Schwab <schwab@suse.de>
Subject: Re: MSEC_TO_JIFFIES is messed up...
Date: Wed, 12 May 2004 22:49:34 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <je4qqlpe01.fsf@sykes.suse.de>
References: <15FDCE057B48784C80836803AE3598D50627ACD5@racerx.ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org-S263718AbUELUtr@vger.kernel.org>
To: Jan Olderdissen <jan@ixiacom.com>
In-Reply-To: <15FDCE057B48784C80836803AE3598D50627ACD5@racerx.ixiacom.com> (Jan
 Olderdissen's message of "Wed, 12 May 2004 13:40:18 -0700")
List-Id: netdev.vger.kernel.org

Jan Olderdissen <jan@ixiacom.com> writes:

> Couple nitpicks:
>
>> #define	MSEC_TO_JIFFIES(msec) (msec * 10)

#define	MSEC_TO_JIFFIES(msec) ((msec) * 10)

>> #define JIFFIES_TO_MESC(jiffies) (jiffies / 10)
>
> #define JIFFIES_TO_MSEC(jiffies) (jiffies / 10)

#define JIFFIES_TO_MSEC(jiffies) ((jiffies) / 10)

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux AG, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
