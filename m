From: Fabian Frederick <fabf@skynet.be>
Subject: Re: [PATCH 6/7 linux-next] wan: cosa: replace current->state by
 set_current_state()
Date: Fri, 20 Feb 2015 19:51:03 +0100 (CET)
Message-ID: <1849761882.58117.1424458263796.open-xchange@webmail.nmp.proximus.be>
References: <1424455977-21903-1-git-send-email-fabf@skynet.be> <1424455977-21903-6-git-send-email-fabf@skynet.be> <54E77E34.6050909@cogentembedded.com>
Reply-To: Fabian Frederick <fabf@skynet.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ingo Molnar <mingo@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	netdev@vger.kernel.org, "Jan \"Yenya\" Kasprzak" <kas@fi.muni.cz>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54E77E34.6050909@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> On 20 February 2015 at 19:34 Sergei Shtylyov
> <sergei.shtylyov@cogentembedded.com> wrote:
>
>
> Hello.
>
> On 02/20/2015 09:12 PM, Fabian Frederick wrote:
>
> > Use helper functions to access current->state.
> > Direct assignments are prone to races and therefore buggy.
>
> > current->state =3D TASK_RUNNING is replaced by __set_current_state(=
)
>
>=C2=A0 =C2=A0 =C2=A0You sometimes use __set_current_state() and someti=
mes set_current_state().
Hello Sergei,

Peter suggested to use __set_current_state() for TASK_RUNNING :
http://marc.info/?l=3Dlinux-kernel&m=3D142442259719216&w=3D2

Regards,
=46abian

>
> > Thanks to Peter Zijlstra for the exact definition of the problem.
>
> > Suggested-By: Peter Zijlstra <peterz@infradead.org>
> > Signed-off-by: Fabian Frederick <fabf@skynet.be>
>
> [...]
>
> WBR, Sergei
>
