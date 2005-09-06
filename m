From: Aidas Kasparas <a.kasparas@gmc.lt>
Subject: Re: Modifying Cryptography Code
Date: Tue, 06 Sep 2005 18:24:42 +0300
Message-ID: <431DB4BA.7040905@gmc.lt>
References: <BAY106-F336464E0C97EA44289AA87ABA70@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: linux-security-module@mail.wirex.com, linux-crypto@nl.linux.org,
	linux-net@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: Alaa Dalghan <alaadalghan@hotmail.com>
In-Reply-To: <BAY106-F336464E0C97EA44289AA87ABA70@phx.gbl>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Alaa Dalghan wrote:
> imposes too much processing overhead on the linux VPN gateway. The
> required behavior is that the VPN gateway just RELAYS encrypted data
> (ESP envelopes) without decrypting them. This is impossible in the
> current ipsec implementation since"the end of a tunnel HAS ALWAYS to be
> decrypted".
> 

That can work only in case when you set esp's encryption keys manually
and the same on all 30 your clients. Also, SPIs should be the same. I
would not call such setup secure.

Better way is to put all these clients into single subnet and configure
them to require transport mode esp transformation in that subnet +
employ automatic keying and auth by certs. And required subset of these
scarry 900 tunnels will set up automatically. [Don't ask me how to
configure this setup in windows -- I don't know].

> I hope that someone can help me with finding this portion of the code
> and modify it. By the way I searched in the kernel file "esp4.c" but
> can't seem to find what I want.

Check xfrm*.c files, also net/xfrm directory.

-- 
Aidas Kasparas
IT administrator
GM Consult Group, UAB
