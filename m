From: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>
Subject: Re: How to pass a string via iwpriv
Date: Wed, 15 Sep 2004 09:18:01 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200409150918.01534.vda@port.imtp.ilyichevsk.odessa.ua>
References: <FD52892BD296D71183B400065BFCB6900F1AA869@il02exm12>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="koi8-r"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: Lewis Adam-CAL022 <Adam.Lewis@motorola.com>, netdev@oss.sgi.com
In-Reply-To: <FD52892BD296D71183B400065BFCB6900F1AA869@il02exm12>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wednesday 15 September 2004 05:58, Lewis Adam-CAL022 wrote:
> Is there a way to create a private extension (e.g. to be invoked by iwpriv)
> that I can pass a string argument?  Looking in wirless.h, I see types for
> byte, float, int, char, etc., but no char*.

example from acx100 driver:

static const struct iw_priv_args acx100_ioctl_private_args[] = {
...
{ cmd : ACX100_IOCTL_SET_RATES,
        set_args : IW_PRIV_TYPE_CHAR | 256,
        get_args : 0,
        name : "SetRates" },
...
--
vda
