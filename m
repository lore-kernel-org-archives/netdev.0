From: Zaboj Campula <zaboj.campula@post.cz>
Subject: Re: [PATCH] iproute2: show network device dependency tree
Date: Tue, 28 Feb 2017 20:07:37 +0000
Message-ID: <1488312457.2131.2.camel@post.cz>
References: <20170225165900.10129-1-zaboj.campula@post.cz>
         <20170225173927.GA2479@nanopsycho> <1488054142.3856.15.camel@post.cz>
         <20170226075633.GA1788@nanopsycho> <1488117614.1903.2.camel@post.cz>
         <20170226144610.GB2071@nanopsycho.orion> <20170227173825.39e00c61@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jiri Benc <jbenc@redhat.com>, Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mxf1.seznam.cz ([77.75.78.123]:42825 "EHLO mxf1.seznam.cz"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751055AbdB1UM1 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 28 Feb 2017 15:12:27 -0500
In-Reply-To: <20170227173825.39e00c61@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-02-27 at 17:38 +0100, Jiri Benc wrote:
> 
> It produces dot (graphviz) output or json and has no dependencies on
> anything GUI related. Just run it on the remote machine and display the
> output locally.
> 
> ssh root@remote plotnetcfg | dot -Tpdf | whatever_pdf_viewer
> 
> Note that some pdf viewers can't read stdin or require dash as the
> parameter to use stdin.
> 
> I don't think it's possible to enhance iproute2 to display the network
> interface dependencies in an useful way. It's just too complex. It's
> not even a (undirected) tree.

I know there is an option to execute something remotely but I think 
a pure text output may be useful to get a quick overview.

Well it is impossible to draw a simple tree showing the configuration
exactly with all details. May be it is too ambitious to draw a tree
at all. But neither directory structure is a tree (when consider links)
and there are a plenty of tools showing directory tree.
