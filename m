From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: RFC: PHY Abstraction Layer II
Date: Thu, 26 May 2005 11:32:18 -0700
Message-ID: <20050526113218.23e44164@dxpl.pdx.osdl.net>
References: <1107b64b01fb8e9a6c84359bb56881a6@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@oss.sgi.com>,
	Embedded PPC Linux list <linuxppc-embedded@ozlabs.org>
Return-path: <linuxppc-embedded-bounces@ozlabs.org>
To: Andy Fleming <afleming@freescale.com>
In-Reply-To: <1107b64b01fb8e9a6c84359bb56881a6@freescale.com>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-embedded>,
	<mailto:linuxppc-embedded-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-embedded>
List-Post: <mailto:linuxppc-embedded@ozlabs.org>
List-Help: <mailto:linuxppc-embedded-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-embedded>,
	<mailto:linuxppc-embedded-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-embedded-bounces@ozlabs.org
Errors-To: linuxppc-embedded-bounces@ozlabs.org
List-Id: netdev.vger.kernel.org

I finally got around to looking at this for the new skge driver.
The Marvell phy code has several issues:
	* hard coded hex values rather than constants
	* doesn't handle restricted autonegotiation
	* it doesn't really help the driver that much there are too
	  many other warts in the hardware.
