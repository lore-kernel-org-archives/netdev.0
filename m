From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Just one more byte, it is wafer thin...
Date: Wed, 20 Jul 2011 17:52:54 -0700
Message-ID: <4E277866.8050603@hp.com>
References: <4E2764A0.90003@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0028.austin.hp.com ([15.216.28.35]:44497 "EHLO
	g1t0028.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751924Ab1GUAw4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2011 20:52:56 -0400
Received: from g1t0038.austin.hp.com (g1t0038.austin.hp.com [16.236.32.44])
	by g1t0028.austin.hp.com (Postfix) with ESMTP id 926EE1C90E
	for <netdev@vger.kernel.org>; Thu, 21 Jul 2011 00:52:54 +0000 (UTC)
Received: from [16.89.244.213] (tardy.cup.hp.com [16.89.244.213])
	by g1t0038.austin.hp.com (Postfix) with ESMTP id 66CE730020
	for <netdev@vger.kernel.org>; Thu, 21 Jul 2011 00:52:54 +0000 (UTC)
In-Reply-To: <4E2764A0.90003@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/20/2011 04:28 PM, Rick Jones wrote:
> and got a somewhat unexpected result - I've no idea why then they both
> went up - perhaps it was sensing "high" occasionally even in the 4344
> byte request case.

That would seem to be the case?  Back to defaults, ./configure'd netperf 
with --enable-demo and have it print-out interim results every 250 
milliseconds (or so)

root@use111814x:~/netperf-2.5.0# HDR="-P 1";for r in 4344 4345; do 
netperf -D 0.25 -H mumble.3.21 -t TCP_RR $HDR -- -r ${r},1; HDR="-P 0"; done
MIGRATED TCP REQUEST/RESPONSE TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET 
to mumble.3.21 (mumble.3.21) port 0 AF_INET : histogram : demo : first 
burst 0
Interim result: 5332.90 Trans/s over 0.28 seconds ending at 1311209347.312
Interim result: 6867.20 Trans/s over 0.25 seconds ending at 1311209347.562
Interim result: 14475.52 Trans/s over 0.25 seconds ending at 1311209347.813
Interim result: 14513.50 Trans/s over 0.25 seconds ending at 1311209348.063
Interim result: 14528.00 Trans/s over 0.25 seconds ending at 1311209348.313
Interim result: 8245.53 Trans/s over 0.44 seconds ending at 1311209348.753
Interim result: 13523.73 Trans/s over 0.25 seconds ending at 1311209349.003
Interim result: 13310.17 Trans/s over 0.26 seconds ending at 1311209349.259
Interim result: 8303.74 Trans/s over 0.40 seconds ending at 1311209349.660
Interim result: 14202.24 Trans/s over 0.25 seconds ending at 1311209349.910
Interim result: 8124.76 Trans/s over 0.44 seconds ending at 1311209350.347
Interim result: 14495.59 Trans/s over 0.25 seconds ending at 1311209350.597
Interim result: 14505.91 Trans/s over 0.25 seconds ending at 1311209350.847
Interim result: 13338.19 Trans/s over 0.27 seconds ending at 1311209351.119
Interim result: 7280.44 Trans/s over 0.46 seconds ending at 1311209351.577
Interim result: 14002.71 Trans/s over 0.25 seconds ending at 1311209351.827
Interim result: 6661.47 Trans/s over 0.53 seconds ending at 1311209352.353
Interim result: 4069.30 Trans/s over 0.41 seconds ending at 1311209352.762
Interim result: 10444.77 Trans/s over 0.35 seconds ending at 1311209353.110
Interim result: 9013.21 Trans/s over 0.29 seconds ending at 1311209353.399
Interim result: 6480.59 Trans/s over 0.35 seconds ending at 1311209353.747
Interim result: 13245.09 Trans/s over 0.25 seconds ending at 1311209353.997
Interim result: 12205.48 Trans/s over 0.30 seconds ending at 1311209354.294
Interim result: 5592.64 Trans/s over 0.55 seconds ending at 1311209354.840
Interim result: 6142.67 Trans/s over 0.59 seconds ending at 1311209355.430
Interim result: 11084.00 Trans/s over 0.25 seconds ending at 1311209355.680
Interim result: 14511.18 Trans/s over 0.25 seconds ending at 1311209355.930
Interim result: 14475.35 Trans/s over 0.25 seconds ending at 1311209356.181
Interim result: 7893.58 Trans/s over 0.46 seconds ending at 1311209356.639
Interim result: 14176.00 Trans/s over 0.25 seconds ending at 1311209356.889
Local /Remote
Socket Size   Request  Resp.   Elapsed  Trans.
Send   Recv   Size     Size    Time     Rate
bytes  Bytes  bytes    bytes   secs.    per sec

16384  87380  4344     1       10.00    9907.27
16384  87380

now the 4345 byte request:

Interim result: 8712.99 Trans/s over 0.37 seconds ending at 1311209357.406
Interim result: 3344.24 Trans/s over 0.65 seconds ending at 1311209358.057
Interim result: 3495.28 Trans/s over 0.25 seconds ending at 1311209358.308
Interim result: 3457.05 Trans/s over 0.25 seconds ending at 1311209358.561
Interim result: 3315.55 Trans/s over 0.26 seconds ending at 1311209358.821
Interim result: 3340.47 Trans/s over 0.25 seconds ending at 1311209359.072
Interim result: 3343.81 Trans/s over 0.25 seconds ending at 1311209359.322
Interim result: 3373.45 Trans/s over 0.25 seconds ending at 1311209359.572
Interim result: 3292.31 Trans/s over 0.26 seconds ending at 1311209359.828
Interim result: 3328.17 Trans/s over 0.25 seconds ending at 1311209360.079
Interim result: 3373.07 Trans/s over 0.25 seconds ending at 1311209360.329
Interim result: 3431.75 Trans/s over 0.25 seconds ending at 1311209360.579
Interim result: 3324.45 Trans/s over 0.26 seconds ending at 1311209360.837
Interim result: 3347.82 Trans/s over 0.25 seconds ending at 1311209361.087
Interim result: 3327.10 Trans/s over 0.25 seconds ending at 1311209361.338
Interim result: 3337.22 Trans/s over 0.25 seconds ending at 1311209361.589
Interim result: 3444.56 Trans/s over 0.25 seconds ending at 1311209361.839
Interim result: 3336.91 Trans/s over 0.26 seconds ending at 1311209362.097
Interim result: 3323.07 Trans/s over 0.25 seconds ending at 1311209362.348
Interim result: 3422.15 Trans/s over 0.25 seconds ending at 1311209362.598
Interim result: 3327.81 Trans/s over 0.26 seconds ending at 1311209362.855
Interim result: 3312.43 Trans/s over 0.25 seconds ending at 1311209363.106
Interim result: 3346.22 Trans/s over 0.25 seconds ending at 1311209363.356
Interim result: 3426.75 Trans/s over 0.25 seconds ending at 1311209363.606
Interim result: 3304.44 Trans/s over 0.26 seconds ending at 1311209363.866
Interim result: 3466.26 Trans/s over 0.25 seconds ending at 1311209364.116
Interim result: 3299.97 Trans/s over 0.26 seconds ending at 1311209364.379
Interim result: 3360.99 Trans/s over 0.25 seconds ending at 1311209364.629
Interim result: 3402.76 Trans/s over 0.25 seconds ending at 1311209364.879
Interim result: 3389.28 Trans/s over 0.25 seconds ending at 1311209365.130
Interim result: 3360.94 Trans/s over 0.25 seconds ending at 1311209365.382
Interim result: 3319.58 Trans/s over 0.25 seconds ending at 1311209365.635
Interim result: 3440.41 Trans/s over 0.25 seconds ending at 1311209365.886
Interim result: 3386.75 Trans/s over 0.25 seconds ending at 1311209366.140
Interim result: 3337.23 Trans/s over 0.25 seconds ending at 1311209366.393
Interim result: 3329.40 Trans/s over 0.25 seconds ending at 1311209366.644
Interim result: 3328.29 Trans/s over 0.25 seconds ending at 1311209366.894
16384  87380  4345     1       10.00    3560.55
16384  87380

  Still, is this suggesting that perhaps the adaptive
> bits are being a bit to aggressive about sensing high? Over what
> interval is that measurement supposed to be happening?
>
> rick jones
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at http://vger.kernel.org/majordomo-info.html

