From: Prabhakar Lad <prabhakar.csengg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: DaVinci Emac Driver Fails to wake up on suspending to RAM
Date: Sun, 13 Oct 2013 12:58:57 +0530
Message-ID: <CA+V-a8vrq7+53FwtEqcwV0FmPHPvsb_E=OWvoqfT_kPAkZoUxw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dlos <davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org>,
        Mugunthan V N
	<mugunthanvnm-l0cyMroinI0@public.gmane.org>, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <davinci-linux-open-source-bounces-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org>
List-Unsubscribe: <http://linux.davincidsp.com/mailman/options/davinci-linux-open-source>,
	<mailto:davinci-linux-open-source-request-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org?subject=unsubscribe>
List-Archive: <http://linux.davincidsp.com/pipermail/davinci-linux-open-source>
List-Post: <mailto:davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org>
List-Help: <mailto:davinci-linux-open-source-request-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org?subject=help>
List-Subscribe: <http://linux.davincidsp.com/mailman/listinfo/davinci-linux-open-source>,
	<mailto:davinci-linux-open-source-request-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org?subject=subscribe>
Sender: <davinci-linux-open-source-bounces-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org>
Errors-To: davinci-linux-open-source-bounces-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

While testing the suspend to RAM on OMAP-L138, I see a issue while waking up
the request irq fails with following log.

Linux version is Linux version 3.12.0-rc2

root@da850-omapl138-evm:~# rtcwake -d /dev/rtc0 -s 20 -m mem
wakeup from "mem" at Sat Jan  1 00:01:47 2000
PM: Syncing filesystems ... done.
Freezing user space processes ... (elapsed 0.001 seconds) done.
Freezing remaining freezable tasks ... (elapsed 0.001 seconds) done.
Suspending console(s) (use no_console_suspend to debug)
PM: suspend of devices complete after 8.693 msecs
PM: suspend devices took 0.010 seconds
PM: late suspend of devices complete after 3.096 msecs
PM: noirq suspend of devices complete after 2.989 msecs
PM: noirq resume of devices complete after 2.396 msecs
PM: early resume of devices complete after 2.851 msecs
genirq: Flags mismatch irq 33. 00000000 (eth0) vs. 00000000 (eth0)
net eth0: DaVinci EMAC: devm_request_irq() failed
PM: resume of devices complete after 15.857 msecs
PM: resume devices took 0.020 seconds
Restarting tasks ... done.
nfs: server 169.254.80.251 not responding, still trying
nfs: server 169.254.80.251 not responding, still trying

-- 
Regards,
--Prabhakar Lad
