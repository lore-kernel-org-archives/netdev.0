From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH] iproute2: show network device dependency tree
Date: Mon, 27 Feb 2017 17:38:25 +0100
Message-ID: <20170227173825.39e00c61@griffin>
References: <20170225165900.10129-1-zaboj.campula@post.cz>
        <20170225173927.GA2479@nanopsycho>
        <1488054142.3856.15.camel@post.cz>
        <20170226075633.GA1788@nanopsycho>
        <1488117614.1903.2.camel@post.cz>
        <20170226144610.GB2071@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Zaboj Campula <zaboj.campula@post.cz>, netdev@vger.kernel.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:26573 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751285AbdB0Qrz (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 27 Feb 2017 11:47:55 -0500
In-Reply-To: <20170226144610.GB2071@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 26 Feb 2017 15:46:10 +0100, Jiri Pirko wrote:
> You can also run it remotelly. Also I believe that you can catch the
> state into some dump file and process it later on. Not 100% sure though.
> Ccing Jiri Benc who is the original author of plotnetcfg.

It produces dot (graphviz) output or json and has no dependencies on
anything GUI related. Just run it on the remote machine and display the
output locally.

ssh root@remote plotnetcfg | dot -Tpdf | whatever_pdf_viewer

Note that some pdf viewers can't read stdin or require dash as the
parameter to use stdin.

I don't think it's possible to enhance iproute2 to display the network
interface dependencies in an useful way. It's just too complex. It's
not even a (undirected) tree.

 Jiri
