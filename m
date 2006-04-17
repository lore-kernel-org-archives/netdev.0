From: "Ian McDonald" <imcdnzl@gmail.com>
Subject: Re: how to do probabilistic packet loss in kernel?
Date: Mon, 17 Apr 2006 14:10:28 +1200
Message-ID: <cbec11ac0604161910t4a89cc9dl96b4ce8f20829883@mail.gmail.com>
References: <4902.128.2.140.224.1145227461.squirrel@128.2.140.224>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: lartc@mailman.ds9a.nl, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0102.google.com ([64.233.162.193]:65488 "EHLO
	nz-out-0102.google.com") by vger.kernel.org with ESMTP
	id S1750935AbWDQCK2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Apr 2006 22:10:28 -0400
Received: by nz-out-0102.google.com with SMTP id 14so389872nzn
        for <netdev@vger.kernel.org>; Sun, 16 Apr 2006 19:10:28 -0700 (PDT)
To: "George P Nychis" <gnychis@cmu.edu>
In-Reply-To: <4902.128.2.140.224.1145227461.squirrel@128.2.140.224>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 4/17/06, George P Nychis <gnychis@cmu.edu> wrote:
> Hi,
>
> I am using iproute2 to setup fowarding, adding routes like "ip route add 192.168.1.3 via 192.168.1.2"
>
> I was wondering where in the kernel I can insert probabilistic packet loss only for forwarded packets?  So that for instance I can drop 5% of all forwarded packets?
>
Have a look at:
http://linux-net.osdl.org/index.php/Netem

--
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
