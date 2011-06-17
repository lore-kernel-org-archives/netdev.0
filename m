From: f6bvp <f6bvp@free.fr>
Subject: Re: [AX25] inconsistent lock state
Date: Fri, 17 Jun 2011 17:26:34 +0200
Message-ID: <4DFB722A.7040304@free.fr>
References: <4B2CD772.1030106@upmc.fr> <20100115203654.GA3084@del.dom.local> <4DFA662D.5030302@free.fr> <201106171536.15660.arnd@arndb.de> <20110617135147.GA3470@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Arnd Bergmann <arnd@arndb.de>, linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>,
	linux-hams@vger.kernel.org
To: Ralf Baechle <ralf@linux-mips.org>
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <20110617135147.GA3470@linux-mips.org>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Ralf,

I wanted to check FPAC ROSE application behaviour when Ethernet link wa=
s=20
shutdown.
To do this I removed the ethernet connector !
I agree this was a very agressive action.

73s de Bernard, f6bvp

Le 17/06/2011 15:51, Ralf Baechle a =E9crit :
> On Fri, Jun 17, 2011 at 03:36:15PM +0200, Arnd Bergmann wrote:
>
> (Removed Jarek from cc; his email bounces.)
>
>> The message hints that disc_data_lock is aquired with softirqs disab=
led,
>> but does not itself disable softirqs, which can in rare circumstance=
s
>> lead to a deadlock.
>>
>> Does this fix it?
> If so, drivers/net/hamradio.c, function sp_get() would probably need =
the
> equivalent fix.  Same for drivers/net/ppp_async.c:ap_get() and sp_get=
() in
> drivers/net/ppp_synctty.c.
>
>    Ralf

--
To unsubscribe from this list: send the line "unsubscribe linux-hams" i=
n
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
