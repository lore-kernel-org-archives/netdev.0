From: Stephen Hemminger <shemminger@osdl.org>
Subject: Fw: [Bug 3610] New: kernel-2.6.9 breaks Amanda
Date: Mon, 25 Oct 2004 16:14:28 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041025161428.3b34b1e7@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="Multipart=_Mon__25_Oct_2004_16_14_28_-0700_JPJTxy13XnFlLmSG"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.

--Multipart=_Mon__25_Oct_2004_16_14_28_-0700_JPJTxy13XnFlLmSG
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit

Here are the traces Bill sent me. No indication of UDP checksum errors.
>
>>Problem Description: Amanda clients exchanges UDP packets with the server giving
>>it a TCP port number with which to connect in order to receive files to be
>>dumped to tape. Under kernel-2.6.8.1 the sofware performs perfectly. Under
>>kernel-2.6.9, with exactly the same Amanda software, the UDP packet exchange
>>seems to occur, but no TCP connection between client and server occurs. The
>>client eventually times out with messages like:
>>    
>>
>
>Could you capture a tcpdump of the exchange, especially the failed connection attempt?
>  
>
Here are two traces, one on the Amanada server machine, one on the 
client machine. Not very useful, as there is no sign that the server 
even attempts to connect to the client with a TCP connection.

---------------------------------------
12:01:25.948611 IP 172.16.240.36.706 > 172.16.240.17.10080: UDP, length 117
12:01:25.951372 IP 172.16.240.17.10080 > 172.16.240.36.706: UDP, length 50
12:01:25.951904 IP 172.16.240.17.10080 > 172.16.240.36.706: UDP, length 83
12:01:25.952031 IP 172.16.240.36.706 > 172.16.240.17.10080: UDP, length 50
12:01:25.952425 IP 172.16.240.36.706 > 172.16.240.17.10080: UDP, length 329
12:01:25.955552 IP 172.16.240.17.10080 > 172.16.240.36.706: UDP, length 50
12:01:26.023487 IP 172.16.240.17.10080 > 172.16.240.36.706: UDP, length 116
12:01:26.023732 IP 172.16.240.36.706 > 172.16.240.17.10080: UDP, length 50
12:01:26.026096 IP 172.16.240.36.710 > 172.16.240.17.10080: UDP, length 236
12:01:26.028704 IP 172.16.240.17.10080 > 172.16.240.36.710: UDP, length 50
12:01:26.032026 IP 172.16.240.17.10080 > 172.16.240.36.710: UDP, length 125
12:01:36.030832 IP 172.16.240.17.10080 > 172.16.240.36.710: UDP, length 125
12:01:46.029536 IP 172.16.240.17.10080 > 172.16.240.36.710: UDP, length 125
12:01:56.028276 IP 172.16.240.17.10080 > 172.16.240.36.710: UDP, length 125
12:02:06.026973 IP 172.16.240.17.10080 > 172.16.240.36.710: UDP, length 125

---------------------------------------

12:01:21.636090 IP 172.16.240.36.706 > 172.16.240.17.10080: UDP, length 117
12:01:21.638787 IP 172.16.240.17.10080 > 172.16.240.36.706: UDP, length 50
12:01:21.639324 IP 172.16.240.17.10080 > 172.16.240.36.706: UDP, length 83
12:01:21.639539 IP 172.16.240.36.706 > 172.16.240.17.10080: UDP, length 50
12:01:21.639982 IP 172.16.240.36.706 > 172.16.240.17.10080: UDP, length 329
12:01:21.642965 IP 172.16.240.17.10080 > 172.16.240.36.706: UDP, length 50
12:01:21.710888 IP 172.16.240.17.10080 > 172.16.240.36.706: UDP, length 116
12:01:21.711239 IP 172.16.240.36.706 > 172.16.240.17.10080: UDP, length 50
12:01:21.713642 IP 172.16.240.36.710 > 172.16.240.17.10080: UDP, length 236
12:01:21.716120 IP 172.16.240.17.10080 > 172.16.240.36.710: UDP, length 50
12:01:21.719435 IP 172.16.240.17.10080 > 172.16.240.36.710: UDP, length 125
12:01:31.718004 IP 172.16.240.17.10080 > 172.16.240.36.710: UDP, length 125
12:01:41.716472 IP 172.16.240.17.10080 > 172.16.240.36.710: UDP, length 125
12:01:51.714977 IP 172.16.240.17.10080 > 172.16.240.36.710: UDP, length 125
12:02:01.713437 IP 172.16.240.17.10080 > 172.16.240.36.710: UDP, length 125
12:12:33.133935 IP 172.16.240.36.32775 > 172.16.240.17.22: P 1:49(48) ack 224 win 7504 <nop,nop,timestamp 6506149 72185367>

--Multipart=_Mon__25_Oct_2004_16_14_28_-0700_JPJTxy13XnFlLmSG
Content-Type: text/plain;
 name="obf_srv.20041022.dmp"
Content-Disposition: attachment;
 filename="obf_srv.20041022.dmp"
Content-Transfer-Encoding: 7bit

12:01:25.948611 IP 172.16.240.36.706 > 172.16.240.17.10080: UDP, length 117
12:01:25.951372 IP 172.16.240.17.10080 > 172.16.240.36.706: UDP, length 50
12:01:25.951904 IP 172.16.240.17.10080 > 172.16.240.36.706: UDP, length 83
12:01:25.952031 IP 172.16.240.36.706 > 172.16.240.17.10080: UDP, length 50
12:01:25.952425 IP 172.16.240.36.706 > 172.16.240.17.10080: UDP, length 329
12:01:25.955552 IP 172.16.240.17.10080 > 172.16.240.36.706: UDP, length 50
12:01:26.023487 IP 172.16.240.17.10080 > 172.16.240.36.706: UDP, length 116
12:01:26.023732 IP 172.16.240.36.706 > 172.16.240.17.10080: UDP, length 50
12:01:26.026096 IP 172.16.240.36.710 > 172.16.240.17.10080: UDP, length 236
12:01:26.028704 IP 172.16.240.17.10080 > 172.16.240.36.710: UDP, length 50
12:01:26.032026 IP 172.16.240.17.10080 > 172.16.240.36.710: UDP, length 125
12:01:36.030832 IP 172.16.240.17.10080 > 172.16.240.36.710: UDP, length 125
12:01:46.029536 IP 172.16.240.17.10080 > 172.16.240.36.710: UDP, length 125
12:01:56.028276 IP 172.16.240.17.10080 > 172.16.240.36.710: UDP, length 125
12:02:06.026973 IP 172.16.240.17.10080 > 172.16.240.36.710: UDP, length 125



--Multipart=_Mon__25_Oct_2004_16_14_28_-0700_JPJTxy13XnFlLmSG
Content-Type: text/plain;
 name="obf_cln.20041022.dmp"
Content-Disposition: attachment;
 filename="obf_cln.20041022.dmp"
Content-Transfer-Encoding: 7bit

12:01:21.636090 IP 172.16.240.36.706 > 172.16.240.17.10080: UDP, length 117
12:01:21.638787 IP 172.16.240.17.10080 > 172.16.240.36.706: UDP, length 50
12:01:21.639324 IP 172.16.240.17.10080 > 172.16.240.36.706: UDP, length 83
12:01:21.639539 IP 172.16.240.36.706 > 172.16.240.17.10080: UDP, length 50
12:01:21.639982 IP 172.16.240.36.706 > 172.16.240.17.10080: UDP, length 329
12:01:21.642965 IP 172.16.240.17.10080 > 172.16.240.36.706: UDP, length 50
12:01:21.710888 IP 172.16.240.17.10080 > 172.16.240.36.706: UDP, length 116
12:01:21.711239 IP 172.16.240.36.706 > 172.16.240.17.10080: UDP, length 50
12:01:21.713642 IP 172.16.240.36.710 > 172.16.240.17.10080: UDP, length 236
12:01:21.716120 IP 172.16.240.17.10080 > 172.16.240.36.710: UDP, length 50
12:01:21.719435 IP 172.16.240.17.10080 > 172.16.240.36.710: UDP, length 125
12:01:31.718004 IP 172.16.240.17.10080 > 172.16.240.36.710: UDP, length 125
12:01:41.716472 IP 172.16.240.17.10080 > 172.16.240.36.710: UDP, length 125
12:01:51.714977 IP 172.16.240.17.10080 > 172.16.240.36.710: UDP, length 125
12:02:01.713437 IP 172.16.240.17.10080 > 172.16.240.36.710: UDP, length 125
12:12:33.133935 IP 172.16.240.36.32775 > 172.16.240.17.22: P 1:49(48) ack 224 win 7504 <nop,nop,timestamp 6506149 72185367>



--Multipart=_Mon__25_Oct_2004_16_14_28_-0700_JPJTxy13XnFlLmSG--
