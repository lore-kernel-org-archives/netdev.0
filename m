From: Christiaan den Besten <chris@scorpion.nl>
Subject: packets displayed twice on ipsec interface ...
Date: Sun, 26 Dec 2004 20:01:10 +0100
Message-ID: <41CF0A76.4060607@scorpion.nl>
Reply-To: chris@scorpion.nl
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi all !

Not really sure this is a kernel, or a netfilter issue, but posting to 
the lkml resulted in no answers so far ;(

After trying to determine the 'overhead' of my ipsec traffic, I hit a 
rather annoying 'feature'.

(Using racoon ipsec with default debian-kernels 2.6.x kernels, but issue 
was with 2.4 as well if i remember correctly.)

Traffic on the outgoing interface (eth0) shows both the encapsulated as 
well as the non-encapsulated packets.

--- (tcpdump -i eth0 -n ) ---
15:24:20.003088 IP 172.20.40.45.45707 > 10.136.100.1.48193: . 
297216:298592(1376) ack 1 win 5792 <nop,nop,timestamp 920412777 2654747912>
15:24:20.005095 IP 130.161.82.9 > 84.35.71.36: 
ESP(spi=0x080d4f70,seq=0x1de7c)
15:24:20.005095 IP 172.20.40.45.45707 > 10.136.100.1.48193: . 
298592:299968(1376) ack 1 win 5792 <nop,nop,timestamp 920412777 2654747912>
15:24:20.005223 IP 84.35.71.36 > 130.161.82.9: 
ESP(spi=0x0451e539,seq=0xee8e)
---

Using default tools a la 'iptraf' counts them both, so it would look 
like my adsl-line is doing 11Mbit :) (which is rather nice since the 
telco has limited it to 6Mbit ...)

Is there any way to prevent the kernel from showing the data inside the 
tunnel ? (172.20.40.45 <> 10.136.100.1 is the tunneled traffic).

bye,
Chris

( Not a member of the list, so a cc would be very nice )
