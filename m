From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 5/5] net: filter: optimize BPF migration for
 ARG1/CTX handling
Date: Thu, 24 Apr 2014 08:28:56 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F6FDD8D@AcuExch.aculab.com>
References: <1398286621-3591-1-git-send-email-dborkman@redhat.com>
	<1398286621-3591-6-git-send-email-dborkman@redhat.com>
	<CAMEtUux3YZW9G80Da2B3pBB2Sq7C7eC62ntnrVifN8_RJugzHw@mail.gmail.com>
	<53583CEB.3040203@redhat.com>
	<CAMEtUuzboCLpVXNd+6NQVco=NbX4wcKHt1F+ZkD7DYVpMbBxEw@mail.gmail.com>
	<5358453E.4050005@redhat.com>
	<CAMEtUuzT6smejsgoKP5c_NCw8mQw39xfPR+hsfV1Oh77ZeG3bA@mail.gmail.com>
 <CAMEtUuy82KA90_0CtkwwZMAXaWbpwtR1RBt9neb1CuX6v-EstA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "David S. Miller" <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>
To: 'Alexei Starovoitov' <ast@plumgrid.com>,
	Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:34201 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752162AbaDXIab convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2014 04:30:31 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 26711-07 for <netdev@vger.kernel.org>;
 Thu, 24 Apr 2014 09:30:23 +0100 (BST)
In-Reply-To: <CAMEtUuy82KA90_0CtkwwZMAXaWbpwtR1RBt9neb1CuX6v-EstA@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov
...
> Have to correct myself here.
> sparc is an architecture where args are passed in %o regs
> and received by the callee in %i regs, so there is a precedent.
...

Not actually true, the parameters are still in the %o regs
in the called function.
It is the called function that rotates the register window,
not the act of making the function call.
Small leaf functions will typically use the existing register
window.

	David
