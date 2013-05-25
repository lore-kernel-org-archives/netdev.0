From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net-next 2/2] openvswitch: Use zerocopy if applicable when
 performing the upcall
Date: Fri, 24 May 2013 17:08:13 -0700
Message-ID: <CAEP_g=_SCmqik=vOQeNF_z7VskG15rovBOLMFx6wPKru0CBDQQ@mail.gmail.com>
References: <cover.1369406826.git.tgraf@suug.ch> <064a09fffe48540b66a3ee503860ed9e8a1eb5f1.1369406826.git.tgraf@suug.ch>
 <CAEP_g=87CuiS92YtCZ1V1ME05qq0jGWD9p1WgKZ2jaaG1AWS7w@mail.gmail.com>
 <1369421900.3301.431.camel@edumazet-glaptop> <CAEP_g=898=iOWV15Y_bcjvS9sGSfDQSP1zQLNkffoXB5imdU7g@mail.gmail.com>
 <1369432621.3301.445.camel@edumazet-glaptop> <CAEP_g=9Yqcf6_cpPYNAbiQUGjQa46PEz6gQdKAopiNNUDRhGYA@mail.gmail.com>
 <1369434870.3301.452.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Thomas Graf <tgraf@suug.ch>, netdev <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog113.obsmtp.com ([74.125.149.209]:40172 "HELO
	na3sys009aog113.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751685Ab3EYAId (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 May 2013 20:08:33 -0400
Received: by mail-ie0-f172.google.com with SMTP id 16so14103278iea.31
        for <netdev@vger.kernel.org>; Fri, 24 May 2013 17:08:33 -0700 (PDT)
In-Reply-To: <1369434870.3301.452.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 24, 2013 at 3:34 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Fri, 2013-05-24 at 15:18 -0700, Jesse Gross wrote:
>
>> Offloads are supported. What I want to know is how they affect
>> performance with this change.
>
> Hmm, I do not understand why you are checksumming then.

Checksum offloading is an internal kernel optimization, so the goal is
to shield userspace from needing to know about it.

> skb_copy_and_csum_dev() is a killer.

What's the alternative?
