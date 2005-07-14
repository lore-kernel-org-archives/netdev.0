From: Jesse Brandeburg <jesse.brandeburg@gmail.com>
Subject: Re: eepro100/e100 broken in 2.6.13-rc3
Date: Wed, 13 Jul 2005 23:28:15 -0700
Message-ID: <4807377b05071323286963bf3a@mail.gmail.com>
References: <20050714034954.52947263@laska>
Reply-To: Jesse Brandeburg <jesse.brandeburg@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S262926AbVGNG3O@vger.kernel.org>
To: Mikhail Kshevetskiy <kl@laska.dorms.spbu.ru>
In-Reply-To: <20050714034954.52947263@laska>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 7/13/05, Mikhail Kshevetskiy <kl@laska.dorms.spbu.ru> wrote:
> symptom
> =======
> modprobe e100
> ifconfig eth0 <ip> netmask <netmask>
> 
> result:
> =======
> SIOCADDRT: Network is unreachable
> 
> There were no such error in 2.6.13-rc2

odd, both e100 and eepro100 are broken?  This might indicate something
wierd with the pci layer.  Don't know what might cause the Network is
unreachable...

please send lspci -vvv of the e100 device in question and any output from dmesg

added netdev in case someone has an idea there.
