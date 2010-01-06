From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [PATCH net-next v2 0/3] can: mscan-mpc5xxx: add support for the
	Freescale MPC512x
Date: Wed, 06 Jan 2010 15:31:12 +0100
Message-ID: <4B449EB0.5090107@grandegger.com>
References: <1262719241-2422-1-git-send-email-wg@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, Devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	Linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
To: Netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <1262719241-2422-1-git-send-email-wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

Wolfgang Grandegger wrote:
> This patch series adds support for the MPC512x from Freescale to
> the mpc5xxx_can MSCAN driver.
> 
> Changes since v1:
> 
> - Various coding style issues, printk formats, variable names and
>   error messagaes and typos fixes or improved
> 
> - MPC5xxx specific data are now passed to mpc5xxx_can_probe() via
>   "of_device_id->data".
> 
> - The index of the MPC512x CAN controller is now derived directly
>   from reg property. This allows use of_iomap() as usual.
> 
> - It has been documented that MPC512x Rev.1 CPUs are not supported.

As you might have already realized, this patch set slipped out
accidentally to the mailing list due to a bug in my
patch-format-test-and-send-email script. Nevertheless, it's good enough
for reviewing and testing. Just some debugging code needs to be removed.
Wolfram, is it OK from your point of view now? I will roll out v3 after
some  more thorough testing tomorrow.

Wolfgang.
