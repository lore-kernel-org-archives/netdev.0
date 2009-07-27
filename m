From: Vlad Dogaru <ddvlad@rosedu.org>
Subject: ESP - Differing Lengths Passed from ESP
Date: Tue, 28 Jul 2009 02:10:59 +0300
Message-ID: <4A6E3403.8090200@rosedu.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from anaconda.cs.pub.ro ([141.85.37.25]:2418 "EHLO
	anaconda.cs.pub.ro" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751110AbZG0XZZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2009 19:25:25 -0400
Received: from [192.168.10.176] (p5.eregie.pub.ro [141.85.0.105])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by anaconda.cs.pub.ro (Postfix) with ESMTP id EE4092E42F0
	for <netdev@vger.kernel.org>; Tue, 28 Jul 2009 02:06:16 +0300 (EEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

Is there any reason that, in an ablkcipher_request, fields nbytes and 
src->length differ by 12 bytes? I'm asking this on netdev since the data 
comes from ESP, apologies if this is inappropriate.

Thanks,
Vlad
