From: Markus Lidel <Markus.Lidel@shadowconnect.com>
Subject: Re: [PATCH] Introduce BROKEN_ON_64BIT facility
Date: Mon, 02 Oct 2006 16:19:34 +0200
Message-ID: <45211FF6.7090303@shadowconnect.com>
References: <20061002045512.GA8835@havoc.gtf.org> <p737izjhwpa.fsf@verdi.suse.de> <4520E1CB.6070104@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <ak@suse.de>, chas@cmf.nrl.navy.mil,
	netdev@vger.kernel.org, kkeil@suse.de, kai.germaschewski@gmx.de,
	isdn4linux@listserv.isdn4linux.de, mac@melware.de,
	samuel@sortiz.org, Neela.Kolli@engenio.com,
	linux-scsi@vger.kernel.org, Greg KH <greg@kroah.com>,
	thomas@winischhofer.net
Return-path: <linux-scsi-owner@vger.kernel.org>
To: Jeff Garzik <jeff@garzik.org>
In-Reply-To: <4520E1CB.6070104@garzik.org>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

Jeff Garzik wrote:
> Andi Kleen wrote:
>> Jeff Garzik <jeff@garzik.org> writes:
>>> Add a broken-on-64bit option, similar to the existing broken-on-smp
>>> config option.  This is just the first pass, marking the obvious
>>> candidates.
>> When I had this problem in the past I just used && !64BIT.
>> How is this new option different?
> Same reason why we have CONFIG_BROKEN_ON_SMP separate from CONFIG_SMP.
>> AFAIK I2O got fixed too. Do you have any evidence that it is really
>> broken on 64bit?
> i2o_config did not.  Just read the code, it's obvious...

Although the documentation does say it need fixes, it really doesn't. It 
is broken if used with 64-bit DMA addresses, but it does work on 64-bit 
systems.



Best regards,


Markus Lidel
------------------------------------------
Markus Lidel (Senior IT Consultant)

Shadow Connect GmbH
Carl-Reisch-Weg 12
D-86381 Krumbach
Germany

Phone:  +49 82 82/99 51-0
Fax:    +49 82 82/99 51-11

E-Mail: Markus.Lidel@shadowconnect.com
URL:    http://www.shadowconnect.com
