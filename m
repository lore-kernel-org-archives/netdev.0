From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [net-next 8/9] i40e: Moving variable declaration out of the
 loops
Date: Fri, 24 Oct 2014 13:10:10 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1C9DE7D1@AcuExch.aculab.com>
References: <1414123806-20049-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1414123806-20049-9-git-send-email-jeffrey.t.kirsher@intel.com>
 <544A4403.9090108@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Akeem G Abodunrin <akeem.g.abodunrin@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"nhorman@redhat.com" <nhorman@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"jogreene@redhat.com" <jogreene@redhat.com>,
	Patrick Lu <patrick.lu@intel.com>
To: 'Sergei Shtylyov' <sergei.shtylyov@cogentembedded.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:57108 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1756167AbaJXNMR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Oct 2014 09:12:17 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 21295-01 for <netdev@vger.kernel.org>;
 Fri, 24 Oct 2014 14:12:06 +0100 (BST)
In-Reply-To: <544A4403.9090108@cogentembedded.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergei Shtylyov
> Hello.
> 
> On 10/24/2014 8:10 AM, Jeff Kirsher wrote:
> 
> > From: Akeem G Abodunrin <akeem.g.abodunrin@intel.com>
> 
> > Move the three variables out of the loop, so it only declares once.
> 
>     It's only declared once in either case. I think gcc allocates maximum
> local variable space at the start of the function, so declaring variables in
> the loop body comes with no extra price.

It won't make much (if any) difference to the generated code.
However it is generally easier for the human reader to find definitions
if they are at the top of the function.

Personally the only time I declare variables in an inner scope is when
that scope is very small.

	David
