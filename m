From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH ] more eepro100 boards
Date: Wed, 19 Nov 2003 12:18:57 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FBBA601.3080709@pobox.com>
References: <3FBA97E4.1060004@wanadoo.es>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Xose Vazquez Perez <xose@wanadoo.es>
In-Reply-To: <3FBA97E4.1060004@wanadoo.es>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Xose Vazquez Perez wrote:
> deleted PCI_DEVICE_ID_INTEL_82801BA_7, it's a  duplicate of 0x2449
> 
> and added five boards:
> 
> 0x1051
> 0x1052
> 0x1053
> 0x1054
> 0x1055
> 
> 
> These should be deleted:
> 
> 0x1035
> 0x1036
> 0x1037
> 0x1227
> 0x1228
> 0x5200
> 0x5201
> 
> Time ago, in conversation with some intel guys, they said me that
> those boards are not compatibles with the driver.  Do anyone run
> eepro100 with any of those boards?


Indeed....  I would like to delay this patch, until we are confirmed 
that these pci ids do indeed work with eepro100.c.  Once we get 
confirmation, I am OK with applying.

	Jeff
