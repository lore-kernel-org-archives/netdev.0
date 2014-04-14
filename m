From: chptx y <chptxy@gmail.com>
Subject: Re: What causes these TCP packet getting lost in linux kernel
Date: Mon, 14 Apr 2014 13:02:16 +0800
Message-ID: <CAMRd1sV_ZzgFF8a2D=CsugHPHrNY=ifV1F46bKVwNSP9FvNPUw@mail.gmail.com>
References: <CAMRd1sXbgcGQuBKd6b-wwkrsqgh_4QicfyR=1hh+TqyYUjYHFA@mail.gmail.com>
	<1397212866.16584.93.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAMRd1sUk_-gtOOgf2dPU_mpgCugDE2F82Te5arnhi+8-uPgm0g@mail.gmail.com>
	<CAJzFV35Z9f-73of0vq2bhUZbN++17cuexcQV4SSSvqJXNyKnRQ@mail.gmail.com>
	<1397331172.4222.8.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Sharat Masetty <sharat04@gmail.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f54.google.com ([209.85.219.54]:52808 "EHLO
	mail-oa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750771AbaDNFCR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2014 01:02:17 -0400
Received: by mail-oa0-f54.google.com with SMTP id n16so8744689oag.13
        for <netdev@vger.kernel.org>; Sun, 13 Apr 2014 22:02:17 -0700 (PDT)
In-Reply-To: <1397331172.4222.8.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Text exporting from wireshark, is it OK?
---------------------------------------------------------------------------------------------------------
Frame 30: 168 bytes on wire (1344 bits), 168 bytes captured (1344 bits)
Transmission Control Protocol, Src Port: http (80), Dst Port: 34865
(34865), Seq: 12517, Ack: 3086, Len: 100
    Source port: http (80)
    Destination port: 34865 (34865)
    [Stream index: 0]
    Sequence number: 12517    (relative sequence number)
    [Next sequence number: 12617    (relative sequence number)]
    Acknowledgement number: 3086    (relative ack number)
    Header length: 32 bytes
    Flags: 0x010 (ACK)
    Window size value: 7541
    [Calculated window size: 7541]
    [Window size scaling factor: 1]
    Checksum: 0x89d8 [correct]
        [Good Checksum: True]
        [Bad Checksum: False]
    Options: (12 bytes)
    [SEQ/ACK analysis]
    [Reassembled PDU in frame: 34]
    TCP segment data (100 bytes)

Frame 31: 68 bytes on wire (544 bits), 68 bytes captured (544 bits)
Transmission Control Protocol, Src Port: 34865 (34865), Dst Port: http
(80), Seq: 3086, Ack: 12617, Len: 0
    Source port: 34865 (34865)
    Destination port: http (80)
    [Stream index: 0]
    Sequence number: 3086    (relative sequence number)
    Acknowledgement number: 12617    (relative ack number)
    Header length: 32 bytes
    Flags: 0x010 (ACK)
    Window size value: 5001
    [Calculated window size: 40008]
    [Window size scaling factor: 8]
    Checksum: 0x8213 [incorrect, should be 0x1614 (maybe caused by
"TCP checksum offload"?)]
        [Good Checksum: False]
        [Bad Checksum: True]
    Options: (12 bytes)
    [SEQ/ACK analysis]

Frame 32: 1416 bytes on wire (11328 bits), 1416 bytes captured (11328 bits)
Transmission Control Protocol, Src Port: http (80), Dst Port: 34865
(34865), Seq: 12617, Ack: 3086, Len: 1348
    Source port: http (80)
    Destination port: 34865 (34865)
    [Stream index: 0]
    Sequence number: 12617    (relative sequence number)
    [Next sequence number: 13965    (relative sequence number)]
    Acknowledgement number: 3086    (relative ack number)
    Header length: 32 bytes
    Flags: 0x010 (ACK)
    Window size value: 7541
    [Calculated window size: 7541]
    [Window size scaling factor: 1]
    Checksum: 0x4139 [correct]
        [Good Checksum: True]
        [Bad Checksum: False]
    Options: (12 bytes)
    [SEQ/ACK analysis]
    [Reassembled PDU in frame: 34]
    TCP segment data (1348 bytes)

Frame 33: 68 bytes on wire (544 bits), 68 bytes captured (544 bits)
Transmission Control Protocol, Src Port: 34865 (34865), Dst Port: http
(80), Seq: 3086, Ack: 12617, Len: 0
    Source port: 34865 (34865)
    Destination port: http (80)
    [Stream index: 0]
    Sequence number: 3086    (relative sequence number)
    Acknowledgement number: 12617    (relative ack number)
    Header length: 32 bytes
    Flags: 0x010 (ACK)
    Window size value: 5001
    [Calculated window size: 40008]
    [Window size scaling factor: 8]
    Checksum: 0x8213 [incorrect, should be 0x1614 (maybe caused by
"TCP checksum offload"?)]
        [Good Checksum: False]
        [Bad Checksum: True]
    Options: (12 bytes)
    [SEQ/ACK analysis]

Frame 34: 687 bytes on wire (5496 bits), 687 bytes captured (5496 bits)
Transmission Control Protocol, Src Port: http (80), Dst Port: 34865
(34865), Seq: 13965, Ack: 3086, Len: 619
    Source port: http (80)
    Destination port: 34865 (34865)
    [Stream index: 0]
    Sequence number: 13965    (relative sequence number)
    [Next sequence number: 14584    (relative sequence number)]
    Acknowledgement number: 3086    (relative ack number)
    Header length: 32 bytes
    Flags: 0x018 (PSH, ACK)
    Window size value: 7541
    [Calculated window size: 7541]
    [Window size scaling factor: 1]
    Checksum: 0xf362 [correct]
        [Good Checksum: True]
        [Bad Checksum: False]
    Options: (12 bytes)
    [SEQ/ACK analysis]
    TCP segment data (619 bytes)
[7 Reassembled TCP Segments (3415 bytes): #28(1348), #30(100),
#32(1348), #38(1348), #40(1348), #34(619), #36(619)]
Hypertext Transfer Protocol
Line-based text data: text/plain

Frame 35: 68 bytes on wire (544 bits), 68 bytes captured (544 bits)
Transmission Control Protocol, Src Port: 34865 (34865), Dst Port: http
(80), Seq: 3086, Ack: 12617, Len: 0
    Source port: 34865 (34865)
    Destination port: http (80)
    [Stream index: 0]
    Sequence number: 3086    (relative sequence number)
    Acknowledgement number: 12617    (relative ack number)
    Header length: 32 bytes
    Flags: 0x010 (ACK)
    Window size value: 5001
    [Calculated window size: 40008]
    [Window size scaling factor: 8]
    Checksum: 0x8213 [incorrect, should be 0x1614 (maybe caused by
"TCP checksum offload"?)]
        [Good Checksum: False]
        [Bad Checksum: True]
    Options: (12 bytes)
    [SEQ/ACK analysis]

Frame 36: 687 bytes on wire (5496 bits), 687 bytes captured (5496 bits)
Transmission Control Protocol, Src Port: http (80), Dst Port: 34865
(34865), Seq: 13965, Ack: 3086, Len: 619
    Source port: http (80)
    Destination port: 34865 (34865)
    [Stream index: 0]
    Sequence number: 13965    (relative sequence number)
    [Next sequence number: 14584    (relative sequence number)]
    Acknowledgement number: 3086    (relative ack number)
    Header length: 32 bytes
    Flags: 0x018 (PSH, ACK)
    Window size value: 7541
    [Calculated window size: 7541]
    [Window size scaling factor: 1]
    Checksum: 0xeb4e [correct]
        [Good Checksum: True]
        [Bad Checksum: False]
    Options: (12 bytes)
    [SEQ/ACK analysis]
    [Reassembled PDU in frame: 34]
    TCP segment data (619 bytes)

Frame 37: 80 bytes on wire (640 bits), 80 bytes captured (640 bits)
Transmission Control Protocol, Src Port: 34865 (34865), Dst Port: http
(80), Seq: 3086, Ack: 12617, Len: 0
    Source port: 34865 (34865)
    Destination port: http (80)
    [Stream index: 0]
    Sequence number: 3086    (relative sequence number)
    Acknowledgement number: 12617    (relative ack number)
    Header length: 44 bytes
    Flags: 0x010 (ACK)
    Window size value: 5001
    [Calculated window size: 40008]
    [Window size scaling factor: 8]
    Checksum: 0x821f [incorrect, should be 0xec6d (maybe caused by
"TCP checksum offload"?)]
        [Good Checksum: False]
        [Bad Checksum: True]
    Options: (24 bytes)
    [SEQ/ACK analysis]

Frame 38: 1416 bytes on wire (11328 bits), 1416 bytes captured (11328 bits)
Transmission Control Protocol, Src Port: http (80), Dst Port: 34865
(34865), Seq: 12617, Ack: 3086, Len: 1348
    Source port: http (80)
    Destination port: 34865 (34865)
    [Stream index: 0]
    Sequence number: 12617    (relative sequence number)
    [Next sequence number: 13965    (relative sequence number)]
    Acknowledgement number: 3086    (relative ack number)
    Header length: 32 bytes
    Flags: 0x010 (ACK)
    Window size value: 7541
    [Calculated window size: 7541]
    [Window size scaling factor: 1]
    Checksum: 0x3925 [correct]
        [Good Checksum: True]
        [Bad Checksum: False]
    Options: (12 bytes)
    [SEQ/ACK analysis]
    [Reassembled PDU in frame: 34]
    TCP segment data (1348 bytes)

Frame 39: 68 bytes on wire (544 bits), 68 bytes captured (544 bits)
Transmission Control Protocol, Src Port: 34865 (34865), Dst Port: http
(80), Seq: 3086, Ack: 14584, Len: 0
    Source port: 34865 (34865)
    Destination port: http (80)
    [Stream index: 0]
    Sequence number: 3086    (relative sequence number)
    Acknowledgement number: 14584    (relative ack number)
    Header length: 32 bytes
    Flags: 0x010 (ACK)
    Window size value: 5246
    [Calculated window size: 41968]
    [Window size scaling factor: 8]
    Checksum: 0x8213 [incorrect, should be 0x0ba3 (maybe caused by
"TCP checksum offload"?)]
        [Good Checksum: False]
        [Bad Checksum: True]
    Options: (12 bytes)
    [SEQ/ACK analysis]

Frame 40: 1416 bytes on wire (11328 bits), 1416 bytes captured (11328 bits)
Transmission Control Protocol, Src Port: http (80), Dst Port: 34865
(34865), Seq: 12617, Ack: 3086, Len: 1348
    Source port: http (80)
    Destination port: 34865 (34865)
    [Stream index: 0]
    Sequence number: 12617    (relative sequence number)
    [Next sequence number: 13965    (relative sequence number)]
    Acknowledgement number: 3086    (relative ack number)
    Header length: 32 bytes
    Flags: 0x010 (ACK)
    Window size value: 7541
    [Calculated window size: 7541]
    [Window size scaling factor: 1]
    Checksum: 0x3844 [correct]
        [Good Checksum: True]
        [Bad Checksum: False]
    Options: (12 bytes)
    [SEQ/ACK analysis]
    [Reassembled PDU in frame: 34]
    TCP segment data (1348 bytes)

Frame 41: 80 bytes on wire (640 bits), 80 bytes captured (640 bits)
Transmission Control Protocol, Src Port: 34865 (34865), Dst Port: http
(80), Seq: 3086, Ack: 14584, Len: 0
    Source port: 34865 (34865)
    Destination port: http (80)
    [Stream index: 0]
    Sequence number: 3086    (relative sequence number)
    Acknowledgement number: 14584    (relative ack number)
    Header length: 44 bytes
    Flags: 0x010 (ACK)
    Window size value: 5293
    [Calculated window size: 42344]
    [Window size scaling factor: 8]
    Checksum: 0x821f [incorrect, should be 0xe985 (maybe caused by
"TCP checksum offload"?)]
        [Good Checksum: False]
        [Bad Checksum: True]
    Options: (24 bytes)
    [SEQ/ACK analysis]

Frame 42: 68 bytes on wire (544 bits), 68 bytes captured (544 bits)
Transmission Control Protocol, Src Port: 34865 (34865), Dst Port: http
(80), Seq: 3086, Ack: 14584, Len: 0
    Source port: 34865 (34865)
    Destination port: http (80)
    [Stream index: 0]
    Sequence number: 3086    (relative sequence number)
    Acknowledgement number: 14584    (relative ack number)
    Header length: 32 bytes
    Flags: 0x011 (FIN, ACK)
    Window size value: 5293
    [Calculated window size: 42344]
    [Window size scaling factor: 8]
    Checksum: 0x8213 [incorrect, should be 0x09a7 (maybe caused by
"TCP checksum offload"?)]
        [Good Checksum: False]
        [Bad Checksum: True]
    Options: (12 bytes)

2014-04-13 3:32 GMT+08:00 Eric Dumazet <eric.dumazet@gmail.com>:
> On Sat, 2014-04-12 at 12:35 -0600, Sharat Masetty wrote:
>> Check /proc/net/netstat and /proc/net/snmp
>>
>> In netstat look for
>>
>> LINUX_MIB_TCPOFODROP and LINUX_MIB_BACKLOGDROP
>
> The packet is not out of order, according to tcpdump.
>
> Note that the receiver reacts to incoming packet, sending a DUPACK, so
> its not a backlogdrop.
>
> tcpdump trace is really incomplete, I asked tcpdump -vv but got nothing
> from chptx, assuming this is a real name.
>
> packet might be rejected because of a zero receiver window, who knows.
>
> I might search in my basement this crystal ball I might have.
>
>
