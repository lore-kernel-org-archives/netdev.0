From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: mm kernel oops with r8169 & named, PREEMPT
Date: Wed, 13 Oct 2004 20:18:40 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041013181840.GA30852@electric-eye.fr.zoreil.com>
References: <9625752b041012230068619e68@mail.gmail.com> <9625752b041013091772e26739@mail.gmail.com> <9625752b04101309182a96fbd2@mail.gmail.com> <200410131129.05657.jdmason@us.ltcfwd.linux.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Danny <dannydaemonic@gmail.com>, netdev@oss.sgi.com, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jon Mason <jdmason@us.ibm.com>
Content-Disposition: inline
In-Reply-To: <200410131129.05657.jdmason@us.ltcfwd.linux.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jon Mason <jdmason@us.ibm.com> :
> Can you confirm that you are running r8169 driver with NAPI and TSO turned on, 
> along with Preemptable Kernel?  Also, I didn't see anything in the Oops 
> specific to the r8169 driver, do you have another adapter available to run 
> the same test on?  Finally, what is your setup (arch, # of cpus, etc)?

Yep, it does not look closely related to the network driver (there are both
eth1 and unknown eth0 btw).

Danny, can your drop the r8169 driver from 2.6.9-rc4-mm1 into vanilla
2.6.9-rc4 and confirm that it works (preempt should not matter) ?

If it does not, disable ACPI, preempt, profiling and publish the new oops.

--
Ueimor
