From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2.6.9-rc2 1/1] r8169: default on disabling PCIDAC
Date: Mon, 20 Sep 2004 15:11:11 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <414F2B4F.3080606@pobox.com>
References: <20040919224102.GA32577@electric-eye.fr.zoreil.com> <414F1DFD.9030008@pobox.com> <20040920190252.GA16429@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Hans-Frieder Vogt <hfvogt@arcor.de>, Andy Lutomirski <luto@myrealbox.com>,
        Jon Mason <jdmason@us.ibm.com>,
        Srihari Vijayaraghavan <sriharivijayaraghavan@yahoo.com.au>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20040920190252.GA16429@electric-eye.fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Francois Romieu wrote:
> Jeff Garzik <jgarzik@pobox.com> :
> [...]
> 
>>Can this interrupt be used at runtime to detect that DAC isn't working?
> 
> 
> Experiment suggests that. 
> 
> Errr... Do you really want to hot-reinit the device ?


It's only a one-time operation that occurs on weird 64-bit boxes :)

I applied the using_dac stuff, but do think there is _some_ better way.

	Jeff
