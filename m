From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: iptables-problem
Date: Sat, 26 Mar 2005 20:13:45 +0100
Message-ID: <20050326191345.GA23316@electric-eye.fr.zoreil.com>
References: <43c5e5aa0503260930732eb697@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
To: backslash46@yahoo.com
Content-Disposition: inline
In-Reply-To: <43c5e5aa0503260930732eb697@mail.gmail.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

amir_sarbazi <amir.sarbazi@gmail.com> :
[...]
>  I used these iptables that SNAT didn't work(Bad
>  argument):
>  iptables -A PREROUTING -t nat -p tcp -d  217.218.68.20 --dport 80 \
>    -j SNAT --to 192.168.1.2:80 or(--to-source 192.168.1.3:80)

$ LANG=en_US man 8 iptables
[...]
   SNAT
       This target is only valid in the nat table, in the POSTROUTING chain.
                                                          ^^^^^^^^^^^
--
Ueimor
