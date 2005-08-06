From: Mateusz Berezecki <mateuszb@gmail.com>
Subject: Re: atheros driver - desc
Date: Sat, 6 Aug 2005 23:38:41 +0200
Message-ID: <20050806213841.GA22383@ntjohd.mshome.net>
References: <42F2D523.9020702@gmail.com> <8764uig7nm.fsf@litku.valo.iki.fi>
Reply-To: Mateusz Berezecki <mateuszb@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kalle.Valo@iki.fi
Return-path: <kernel-mentors-bounces@selenic.com>
To: kernel-mentors@selenic.com, netdev <netdev@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <8764uig7nm.fsf@litku.valo.iki.fi>
List-Unsubscribe: <http://selenic.com/mailman/listinfo/kernel-mentors>,
	<mailto:kernel-mentors-request@selenic.com?subject=unsubscribe>
List-Archive: <http://www.selenic.com/pipermail/kernel-mentors>
List-Post: <mailto:kernel-mentors@selenic.com>
List-Help: <mailto:kernel-mentors-request@selenic.com?subject=help>
List-Subscribe: <http://selenic.com/mailman/listinfo/kernel-mentors>,
	<mailto:kernel-mentors-request@selenic.com?subject=subscribe>
Sender: kernel-mentors-bounces@selenic.com
Errors-To: kernel-mentors-bounces@selenic.com
List-Id: netdev.vger.kernel.org

Kalle Valo <Kalle.Valo@iki.fi> wrote:
| 
| This is great news. An open source Atheros driver which could be
| included to Linux is really needed.
| 
| But how was the reverse engineering done? I noticed that forcedeth
| driver was implemented using the clean room design[1] and Linux
| Broadcom 4301 driver project[2] seems to be using the same method.

  Reverse engineering was done by dissassemblying binary HAL
  and in harder parts by running it in userspace(yes, that is possible)
  and analysing input and produced output. The crucial part was to
  discover the meaning of hidden part of the structure describing
  device state. Once this was done it will be a little if no problem to me
  to provide updates for this driver, unless the whole binary HAL
  changes dramatically. That's one of the reasons I do this work myself.
  
| 
| The reason I'm asking this is that I just wouldn't want see the same
| happening this with this driver as happened during reverse engineering
| of pwc Philips Webcam driver (some parts of the driver were removed
| from kernel, but I believe the situation is now solved).

  If get into trouble I write documentation :-) I promise.


| Actually, what are requirements to get a reverse engineered driver
| included to Linux? Is clean room design an absolute must? It seems
| that reverse engineering is needed if we want Linux support for most
| of the WLAN cards on the market :(
| 

   Sad but true. The problem is not at vendors' side though.
   Look at FCC regulations... :/


   kind regards
   Mateusz
