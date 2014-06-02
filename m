From: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Subject: Re: [PATCH] atm: fore200e.c: Cleaning up uninitialized variables
Date: Mon, 2 Jun 2014 21:40:05 +0200
Message-ID: <CAFo99gbpPjobGmEgWcJLRMV29NO1msHooGiQdQRh6hKQ9OPCBw@mail.gmail.com>
References: <1401577712-4447-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
	<CAOesGMi4SGRP6_WMgv3xz_QrGScktYGQEK-muCrE=ohFBfeBeQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Chas Williams <chas@cmf.nrl.navy.mil>,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <robh+dt@kernel.org>,
	linux-atm-general@lists.sourceforge.net,
	Network Development <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>
To: Olof Johansson <olof@lixom.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAOesGMi4SGRP6_WMgv3xz_QrGScktYGQEK-muCrE=ohFBfeBeQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi

No, regardless if it is a program that cppcheck or myself with limited
experience of kernel programming is not so easy to figure out.

But then I know that there is nothing wrong in this case, and that is
the main thing :-)

Best regards
Rickard Strandqvist


2014-06-02 2:10 GMT+02:00 Olof Johansson <olof@lixom.net>:
> On Sat, May 31, 2014 at 4:08 PM, Rickard Strandqvist
> <rickard_strandqvist@spectrumdigital.se> wrote:
>> There is a risk that the variable will be used without being initialized.
>>
>> This was largely found by using a static code analysis program called cppcheck.
>>
>> Signed-off-by: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
>> ---
>>  drivers/atm/fore200e.c |    2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/drivers/atm/fore200e.c b/drivers/atm/fore200e.c
>> index 204814e..d4725fc 100644
>> --- a/drivers/atm/fore200e.c
>> +++ b/drivers/atm/fore200e.c
>> @@ -2780,7 +2780,7 @@ static struct pci_driver fore200e_pca_driver = {
>>
>>  static int __init fore200e_module_init(void)
>>  {
>> -       int err;
>> +       int err = 0;
>>
>>         printk(FORE200E "FORE Systems 200E-series ATM driver - version " FORE200E_VERSION "\n");
>
>
> I can see how a tool that doesn't know about Kconfig dependencies
> might think so, but if you look at Kconfig you'll see that for this
> driver to be enabled for building either CONFIG_SBUS or CONFIG_PCI
> must be set, and if either of them is then this variable will not be
> used without first being set.
>
>
> -Olof
