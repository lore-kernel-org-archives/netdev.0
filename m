From: Harshal Nemade <hanemade@gmail.com>
Subject: loopback packet processing.
Date: Tue, 14 Dec 2004 16:12:26 +0530
Message-ID: <cfc9593604121402424f2a9ba5@mail.gmail.com>
Reply-To: Harshal Nemade <hanemade@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi all,
       I want to know that when i send a packet on loopback on
127.0.0.1 the packet is given to netif_rx without MAC header adding. I
want to know Is that correct? If yes then what happen to that 14 byte
MAC header bytes space in case Ping packet? Is that space free? Why
eth_type_trans is called that checks eth->h_proto field ?
     Please correct me if i am wrong.
Thanks in advance,
harsh.
