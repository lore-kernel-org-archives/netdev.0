From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [BK PATCH] [IPV6] Multiple locking fixes/improvements
Date: Tue, 23 Nov 2004 07:58:12 -0500 (EST)
Message-ID: <20041123.075812.124823013.yoshfuji@linux-ipv6.org>
References: <20041122.223205.14979415.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
 boundary="--Next_Part(Tue_Nov_23_07:58:13_2004_869)--"
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
In-Reply-To: <20041122.223205.14979415.yoshfuji@linux-ipv6.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

----Next_Part(Tue_Nov_23_07:58:13_2004_869)--
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit

In article <20041122.223205.14979415.yoshfuji@linux-ipv6.org> (at Mon, 22 Nov 2004 22:32:05 -0500 (EST)), YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> says:

> @@ -578,6 +571,9 @@
>  	}
>  
>  	return ifa;
> +out:
> +	write_unlock(&addrconf_hash_lock);
> +	goto out;
>  }

Oops, I made a mistake during cleaning up changeset.
I've fixed a typo ("goto out" should be "goto out2")
in the same bk tree:
   <bk://bk.skbuff.net:20610/linux-2.6-inet6/>

Thanks.

ChangeSet@1.2231, 2004-11-23 11:50:54+09:00, yoshfuji@linux-ipv6.org
  [IPV6] Fix possible dead-lock in ipv6_create_tempaddr().
ChangeSet@1.2232, 2004-11-23 11:52:57+09:00, yoshfuji@linux-ipv6.org
  [IPV6] Fix a race when dad completed during shutting down its owner interface.
ChangeSet@1.2233, 2004-11-23 11:54:38+09:00, yoshfuji@linux-ipv6.org
  [IPV6] Stop DAD during shutting down the interface.
ChangeSet@1.2234, 2004-11-23 21:50:01+09:00, yoshfuji@linux-ipv6.org
  [IPV6] Clean-up locking in ipv6_add_addr().

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA

----Next_Part(Tue_Nov_23_07:58:13_2004_869)--
Content-Type: Application/Octet-Stream
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="linux-2.6.10-inet6.cset.bz2"

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

----Next_Part(Tue_Nov_23_07:58:13_2004_869)----
