From: "Kris Op de Beeck" <kris.op.de.beeck@newtec.eu>
Subject: Re: DNAT sporadically doesn't replace destination IP address
Date: Tue, 27 May 2008 16:27:06 +0200
Message-ID: <483C365A.B932.00FE.0@newtec.eu>
References: <4835A03D.B932.00FE.0@newtec.eu> <483589C0.4080006@trash.net>
 <4835ABD2.B932.00FE.0@newtec.eu> <4835913A.4020909@trash.net>
 <4835AE9B.B932.00FE.0@newtec.eu> <48359F66.50503@trash.net>
 <4836EDCE.B932.00FE.0@newtec.eu> <483AC787.6030902@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: "Ulrik De Bie" <ulrik.debie@newtec.eu>, <netdev@vger.kernel.org>,
	"Netfilter Development Mailinglist" <netfilter-devel@vger.kernel.org>
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <483AC787.6030902@trash.net>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> What does "grep <srcport from above> /proc/net/nf_conntrack" show
> when the problem occurs?
> 
[ 1976.495472] nf_ct_tcp: invalid packet ignored IN= OUT= SRC=192.168.1.29 DST=10.9.9.28 LEN=60 TOS=0x00 PREC=0x00 TTL=64 ID=58096 DF PROTO=TCP SPT=41675 DPT=80 SEQ=3967333855 ACK=0 WINDOW=5840 RES=0x00 SYN URGP=0 OPT (020405B40402080A00065A1E0000000001030305) UID=1000

 sudo grep 41675 /proc/net/nf_conntrack
ipv4     2 tcp      6 43 SYN_RECV src=192.168.1.29 dst=10.9.9.28 sport=41675 dport=80 packets=1 bytes=60 src=192.168.1.1 dst=192.168.1.29 sport=80 dport=41675 packets=3 bytes=180 mark=0 secmark=0 use=1


Newtec will be present at the following exhibitions :

CommunicAsia, 17-20 June, Singapore, Booth 6B2-01

*** e-mail confidentiality footer ***
This message and any attachments thereto are confidential. They may also
be privileged or otherwise protected by work product immunity or other
legal rules. If you have received it by mistake, please let us know by
e-mail reply and delete it from your system; you may not copy this
message or disclose its contents to anyone.
E-mail transmission cannot be guaranteed to be secure or error free as
information could be intercepted, corrupted, lost, destroyed, arrive
late or incomplete, or contain viruses. The sender therefore is in no
way liable for any errors or omissions in the content of this message,
which may arise as a result of e-mail transmission. If verification is
required, please request a hard copy.

