From: Jonathan Morton <chromatix99@gmail.com>
Subject: Re: ECN + pfifo_fast borked? (Was Re: [Bloat] shaper team forming up)
Date: Tue, 15 Mar 2011 20:37:04 +0200
Message-ID: <7CFAAB08-8A30-4569-8825-64121D43EA77@gmail.com>
References: <87wrk1a4gx.fsf@cruithne.co.teklibre.org> <5BC42741-852B-4699-BA5D-D70B8D610D96@gmail.com> <1300134277.2649.19.camel@edumazet-laptop> <1300164166.2649.70.camel@edumazet-laptop> <87ipvlosvz.fsf_-_@cruithne.co.teklibre.org> <1300169749.2649.142.camel@edumazet-laptop> <3D05C1F1-B75E-426B-8267-6DB5323A839D@gmail.com> <1300213714.2927.37.camel@edumazet-laptop>
Mime-Version: 1.0 (Apple Message framework v1082)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: =?iso-8859-1?Q?Dave_T=E4ht?= <d@taht.net>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:49378 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753210Ab1COShH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Mar 2011 14:37:07 -0400
Received: by wwk4 with SMTP id 4so3209130wwk.1
        for <netdev@vger.kernel.org>; Tue, 15 Mar 2011 11:37:06 -0700 (PDT)
In-Reply-To: <1300213714.2927.37.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 15 Mar, 2011, at 8:28 pm, Eric Dumazet wrote:

>>> band 0 : high priority packets (like now)
>>> band 1 : (old band 1, ECN capable flows)
>>> band 2 : (old band 1, no ECN flows)
>>> band 3 : low priority packets (old band 2)
>> 
>> This seems good to me.  It would provide a concrete (if minor) enticement to turn ECN on.
> 
> Here is a patch to implement that, on top of net-next-2.6 git tree

Does this take both ECN bits into account?  The ECT(0), ECT(1) and ECE codepoints all need to be recognised equally.

 - Jonathan

