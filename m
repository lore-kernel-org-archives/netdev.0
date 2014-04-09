From: Francois WELLENREITER <f.wellenreiter@gmail.com>
Subject: Does IPv6 support Jumbograms ?
Date: Wed, 09 Apr 2014 21:42:43 +0200
Message-ID: <5345A2B3.7040602@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:55302 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932847AbaDITmr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Apr 2014 15:42:47 -0400
Received: by mail-wi0-f175.google.com with SMTP id cc10so9523036wib.14
        for <netdev@vger.kernel.org>; Wed, 09 Apr 2014 12:42:46 -0700 (PDT)
Received: from ?IPv6:2a01:e34:ef74:28b0:2289:84ff:fea6:56c1? ([2a01:e34:ef74:28b0:2289:84ff:fea6:56c1])
        by mx.google.com with ESMTPSA id h19sm6252471wiw.17.2014.04.09.12.42.44
        for <netdev@vger.kernel.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 09 Apr 2014 12:42:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi there,

I've been recently running performance tests with the loopback interfac=
e
increasing the MTU over the 65535 byte limit.
I was really surprised to see that a simple scp onto the ::1 address
systematically blocked after transferring about 2,4 MB.
My interpretation of this behavior is that the current IPv6 kernel laye=
r
does not support Jumbograms at all. Am I wrong ?
If that's not the case, what could then the right interpretation of thi=
s
issue ?
And whenever I'm right, is there any plan to support this feature in a
near future ?

Thanks in advance for any help.
Regards,

                  Fran=E7ois
