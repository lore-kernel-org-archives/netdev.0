From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [patch 03/13] drivers/net/myri_code.h cleanup
Date: Tue, 22 Mar 2005 17:49:30 -0500
Message-ID: <4240A0FA.90807@pobox.com>
References: <200503152222.j2FMMZ1i016799@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@oss.sgi.com
To: akpm@osdl.org, domen@coderock.org
In-Reply-To: <200503152222.j2FMMZ1i016799@shell0.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

akpm@osdl.org wrote:
> From: Domen Puncer <domen@coderock.org>
> 
> Replace
> 
> 	static unsigned char lanai4_data[20472] __initdata = {
> 		<thousands of 0x00's>
> 	}
> 
> with
> 
> 	static unsigned char lanai4_data[20472] __initdata = { };

Proper change:  Don't bother with an initializer at all.  it's static.

	Jeff
