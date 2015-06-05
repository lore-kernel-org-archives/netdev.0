From: Robert Shearman <rshearma@brocade.com>
Subject: Re: [PATCH WIP RFC 0/3] mpls: support for ler
Date: Fri, 5 Jun 2015 15:31:48 +0100
Message-ID: <5571B2D4.2040807@brocade.com>
References: <1433341306-29288-1-git-send-email-roopa@cumulusnetworks.com> <20150605091441.GA11896@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <ebiederm@xmission.com>, <netdev@vger.kernel.org>
To: Thomas Graf <tgraf@suug.ch>,
	Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:36916 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932313AbbFEOcD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Jun 2015 10:32:03 -0400
In-Reply-To: <20150605091441.GA11896@pox.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/06/15 10:14, Thomas Graf wrote:
> As I mentioned to Robert, the new RTA_ENCAP should be a list of
> Netlink attributes from the beginning to make it extendible without
> ever breaking user ABI.

Just to be clear in both of our approaches, the contents of the 
RTA_ENCAP data is interpreted by the encap owner. Therefore, if the mpls 
encap doesn't consist of nested attributes then it doesn't preculde 
vxlan, for example, consisting of nested attributes.

I do agree though that the netlink format for specifying mpls encap 
should support nested attributes from day 1 to allow it to be extended 
without breaking the ABI.

Thanks,
Rob
