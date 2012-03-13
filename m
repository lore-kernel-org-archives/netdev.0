From: santosh prasad nayak <santoshprasadnayak@gmail.com>
Subject: Re: [PATCH 3/3 v3] netxen: qlogic ethernet : Fix endian bug.
Date: Tue, 13 Mar 2012 14:05:24 +0530
Message-ID: <CAOD=uF6e_JKaEQbFV=78JmuMBSUOtP7L0cBZr2zSv+Zgwq==qQ@mail.gmail.com>
References: <1331624093-12598-1-git-send-email-santoshprasadnayak@gmail.com>
	<20120313.010406.769202674785007195.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: sony.chacko@qlogic.com, rajesh.borundia@qlogic.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120313.010406.769202674785007195.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

My mistake.
Normally I compile before sending the patch. This time I forgot.

Sorry for the inconvenience.


regards
Santosh

On Tue, Mar 13, 2012 at 1:34 PM, David Miller <davem@davemloft.net> wro=
te:
>
> You didn't even compile test this.
>
>> - =A0 =A0 if (*mac =3D=3D cpu_to_le64(~0ULL)) {
>> + =A0 =A0 if (*mac =3D=3D ~0ULL)) {
>
> This is unacceptable, I'm ignoring you for at least a week.
>
