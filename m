From: Sunil Kovvuri <sunil.kovvuri@gmail.com>
Subject: Re: [PATCH 1/2] net: thunderx: HW TSO support for pass-2 hardware
Date: Wed, 9 Dec 2015 17:54:16 +0530
Message-ID: <CA+sq2CfsvmTAvwHuyd9-6WLbPHB1JNpm5JXEPQemxs7=uL9LZQ@mail.gmail.com>
References: <y@samsung.com>
	<1449661081-15435-2-git-send-email-sunil.kovvuri@gmail.com>
	<00b701d13279$d54d9c80$7fe8d580$@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	LAKML <linux-arm-kernel@lists.infradead.org>,
	Sunil Goutham <Sunil.Goutham@caviumnetworks.com>,
	Sunil Goutham <sgoutham@cavium.com>
To: Pavel Fedin <p.fedin@samsung.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <00b701d13279$d54d9c80$7fe8d580$@samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>> +     bool                    tns_mode:1;
>> +     bool                    sqs_mode:1;

 >These little refactors are creeping in your code without even being
mentioned in the commit message, this is not good practice.
Okay, will include these in the commit message.

>IMHO. Additionally, may be turn these two flags into something like:

>enum nicvf_mode {
>        NICVF_BYPASS,
>        NICVF_TNS,
>        NICVF_SQS
>};

 >? Anyway, these modes are mutually exclusive.
VF driver always assumed to be in BYPASS mode.
Will submit a seperate cleanup patch to get rid of 'tns_mode' boolean.

Thanks,
Sunil.
