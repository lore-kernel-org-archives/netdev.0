From: cranium 2003 <cranium.2003@gmail.com>
Subject: Which function at link layer sends packet?
Date: Thu, 3 Feb 2005 18:48:19 +0530
Message-ID: <1d55641b05020305182d423c57@mail.gmail.com>
Reply-To: cranium 2003 <cranium.2003@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, kernelnewbies <kernelnewbies@nl.linux.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello,
       In a LAN  i have 2 pcs host1 with 10.0.2.10 and host2 with
eth0:10.0.0.100 and eth1:192.168.1.1 Both are connected to switch.
what i observe that when i ping from 10.0.2.10 to 192.168.1.1 then
packet  is sent through dev_queue_xmit_nit. In that function it goes
upto ptype->func(skb2, skb->dev, ptype);
and then i am not getting which functions get called but then i found
call goes to ethernet driver to NIC card. Does that mean above
statement calls hard_start_xmit?
      Then i reboot my linux RH9 with 2.4.24 kernel PC and again ping
to 192.168.1.1 and found that packet transmission  is not going
through dev_queu_xmit_nit but from dev_queue_xmit to hard_start_xmit.
regards,
cranium.
